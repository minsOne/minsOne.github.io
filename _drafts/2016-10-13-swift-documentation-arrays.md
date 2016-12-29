---
layout: post
title: "swift documentation arrays"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

### 목표

1. Performance equivalent to C arrays for subscript get/set of
   non-class element types is the most important performance goal.

1. C 배열과 같은 성능 클래스가 아닌 요소 타입의 get/set 서브스크립트를 위한 가 가장 중요한 성능 목표이다.  

2. It should be possible to receive an ``NSArray`` from Cocoa,
   represent it as an ``Array<AnyObject>``, and pass it right back to
   Cocoa as an ``NSArray`` in O(1) and with no memory allocations.

2. Cocoa에서 NSArray를 받는 것이 가능해야 하며, Array<AnyObject>로 표시되어야 하고, 바로 Cocoa에 NSArray로 전달해야 하며, O(1)과 메모리 할당이 없어야 합니다.

3. Arrays should be usable as stacks, so we want amortized O(1) append
   and O(1) popBack.  Together with goal #1, this implies a
   ``std::vector``\ -like layout, with a reserved tail memory capacity
   that can exceed the number of actual stored elements.

3. 배열은 스택으로 사용할 수 있어야 하며, 균등하게 O(1)로 추가와 O(1)로 popBack을 바랍니다. 목표 #1에 덧붙여, 배열은 `std::vector`와 비슷한 레이아웃과, 실제 저장된 요소의 수를 넘어설 수 있는 별도의 tail 메모리 용량을 의미합니다.

To achieve goals 1 and 2 together, we use static knowledge of the
element type: when it is statically known that the element type is not
a class, code and checks accounting for the possibility of wrapping an
``NSArray`` are eliminated.  An ``Array`` of Swift value types always
uses the most efficient possible representation, identical to that of
``ContiguousArray``.

목표 1과 2를 이루기 위해, 요소 타입의 정적 지식을 사용합니다: 정적으로 알려진 요소의 타입이 클래스가 아니면, NSArray 포장 가능성을 차지하는 코드와 검사가 제거됩니다. Swift 값 타입의 `Array`는 항상 가장 효율적으로 가능한 표현식을 사용하며, `ContiguousArray`와 동일합니다.

### 구성요소

Swift provides three generic array types, all of which have amortized
O(1) growth.  In this document, statements about **ArrayType** apply
to all three of the components.

Swift는 세가지 제네릭 배열 타입을 제공하며, 모두 균등하게 O(1) 증가를 가집니다. 이 문서에서 **ArrayType** 상태는 세 가지 구성 요소 모두에 적용됩니다.

* ``ContiguousArray<Element>`` is the fastest and simplest of the three—use
  this when you need "C array" performance.  The elements of a
  ``ContiguousArray`` are always stored contiguously in memory.

* `ContiguousArray<Element>`는 세 가지 중에 가장 빠르고 간단합니다 "C 배열" 성능이 필요할 때 사용합니다. `ContiguousArray` 요소는 항상 연속으로 메모리에 저장됩니다.

  .. image:: ContiguousArray.png

* ``Array<Element>`` is like ``ContiguousArray<Element>``, but optimized for
  efficient conversions from Cocoa and back—when ``Element`` can be a class
  type, ``Array<Element>`` can be backed by the (potentially non-contiguous)
  storage of an arbitrary ``NSArray`` rather than by a Swift
  ``ContiguousArray``.  ``Array<Element>`` also supports up- and downcasts
  between arrays of related class types.  When ``Element`` is known to be a
  non-class type, the performance of ``Array<Element>`` is identical to that
  of ``ContiguousArray<Element>``.

* `Array<Element>`는 `ContiguousArray<Element>`와 비슷하지만 Cocoa를 오가는 효율적인 전환을 위해 최적화되었으며, `Element`가 클래스 타입일 때 `Array<Element>`는 Swift의 `ContiguousArray` 보다는 (잠재적 비 연속적인)임의의 `NSArray`에 저장하여 백업할 수 있습니다. `Array<Element>`는 관련있는 클래스 타입의 배열 간의 타입 변환을 지원합니다. `Element`는 클래스가 아닌 타입으로 알려졌을 때 `Array<Element>` 성능은 `ContiguousArray<Element>`와 동일합니다.

  .. image:: ArrayImplementation.png

* ``ArraySlice<Element>`` is a subrange of some ``Array<Element>`` or
  ``ContiguousArray<Element>``; it's the result of using slice notation,
  e.g. ``a[7...21]`` on any Swift array ``a``.  A slice always has
  contiguous storage and "C array" performance.  Slicing an
  *ArrayType* is O(1) unless the source is an ``Array<Element>`` backed by
  an ``NSArray`` that doesn't supply contiguous storage.

  `ArraySlice<Element>`는 `Array<Element>` 또는 `ContiguousArray<Element>`의 일부분입니다; 이는 슬라이스 표기 사용의 결과로 Swift 배열 `a`에 `a[7...21]`입니다. 슬라이스는 항상 연속적인 저장 공간과 C 배열 성능을 가집니다. *ArrayType* 슬라이스는 소스가 연속적인 저장공간을 지원하지 않는 `NSArray`에 의한 `Array<Element>`가 아닌 이상 O(1)입니다.

  ``ArraySlice`` is recommended for transient computations but not for
  long-term storage.  Since it references a sub-range of some shared
  backing buffer, a ``ArraySlice`` may artificially prolong the lifetime of
  elements outside the ``ArraySlice`` itself.

  `ArraySlice`는 짧게 계산하는데 추천하지만 장기 저장에 권장하지 않습니다. 일부 공유 백업 버퍼의 일부를 참조하기 때문에, `ArraySlice`는 `ArraySlice` 자체의 외부 요소의 수명을 부자연스럽게 연장합니다.

  .. image:: Slice.png

Mutation Semantics
변경 의미론
------------------

The *ArrayType*\ s have full value semantics via copy-on-write (COW)::

*ArrayType*은 copy-on-write(COW)를 통해 완전한 값 의미를 가집니다.

  var a = [1, 2, 3]
  let b = a
  a[1] = 42
  print(b[1]) // prints "2"

Bridging Rules and Terminology for all Types
모든 타입에 대한 규칙 및 용어 중개
--------------------------------------------

* Every class type or ``@objc`` existential (such as ``AnyObject``) is
  **bridged** to Objective-C and **bridged back** to Swift via the
  identity transformation, i.e. it is **bridged verbatim**.

* 모든 클래스 타입 또는 `@objc` 존재한 타입(예를 들어 `AnyObject`)은 동일한 변화를 통해 Objective-C에 브릿지가 되고 Swift에서 돌아오는 브릿지가 됩니다. 즉, 이것은 브릿지 요약(?)입니다.

* A type ``T`` that is not `bridged verbatim`_ can conform to
  ``BridgedToObjectiveC``, which specifies its conversions to and from
  ObjectiveC::

* 타입 `T`는 `브릿지 요약`이 아니며 `BridgedToObjectiveC`에 적합할 수 있으며, BridgedToObjectiveC는 ObjectiveC에서와 ObjectiveC로 변환을 지정합니다.

    protocol _BridgedToObjectiveC {
      typealias _ObjectiveCType: AnyObject
      func _bridgeToObjectiveC() -> _ObjectiveCType
      class func _forceBridgeFromObjectiveC(_: _ObjectiveCType) -> Self
    }

  .. Note:: Classes and ``@objc`` existentials shall not conform to
     ``_BridgedToObjectiveC``, a restriction that's not currently
     enforceable at compile-time.

주의
클래스와 @objc 존재는 _BridgedToObjectiveC가 적합하지 않으며, 현재 컴파일 타임에 실행할 수 없다는 제한.

* Some generic types (*ArrayType*\ ``<T>`` in particular) bridge to
  Objective-C only if their element types bridge.  These types conform
  to ``_ConditionallyBridgedToObjectiveC``::

    protocol _ConditionallyBridgedToObjectiveC : _BridgedToObjectiveC {
      class func _isBridgedToObjectiveC() -> Bool
      class func _conditionallyBridgeFromObjectiveC(_: _ObjectiveCType) -> Self?
    }

  Bridging from, or *bridging back* to, a type ``T`` conforming to
  ``_ConditionallyBridgedToObjectiveC`` when
  ``T._isBridgedToObjectiveC()`` is ``false`` is a user programming
  error that may be diagnosed at
  runtime. ``_conditionallyBridgeFromObjectiveC`` can be used to attempt
  to bridge back, and return ``nil`` if the entire object cannot be
  bridged.

  .. Admonition:: Implementation Note

     There are various ways to move this detection to compile-time

* For a type ``T`` that is not `bridged verbatim`_,

  - if ``T`` conforms to ``BridgedToObjectiveC`` and either

    - ``T`` does not conform to ``_ConditionallyBridgedToObjectiveC``
    - or, ``T._isBridgedToObjectiveC()``

    then a value ``x`` of type ``T`` is **bridged** as
    ``T._ObjectiveCType`` via ``x._bridgeToObjectiveC()``, and an object
    ``y`` of ``T._ObjectiveCType`` is **bridged back** to ``T`` via
    ``T._forceBridgeFromObjectiveC(y)``

  - Otherwise, ``T`` **does not bridge** to Objective-C

``Array`` Type Conversions
--------------------------

From here on, this document deals only with ``Array`` itself, and not
``Slice`` or ``ContiguousArray``, which support a subset of ``Array``\
's conversions.  Future revisions will add descriptions of ``Slice``
and ``ContiguousArray`` conversions.

Kinds of Conversions
::::::::::::::::::::

In these definitions, ``Base`` is ``AnyObject`` or a trivial subtype
thereof, ``Derived`` is a trivial subtype of ``Base``, and ``X``
conforms to ``_BridgedToObjectiveC``:

.. _trivial bridging:

* **Trivial bridging** implicitly converts ``[Base]`` to
  ``NSArray`` in O(1). This is simply a matter of returning the
  Array's internal buffer, which is-a ``NSArray``.

.. _trivial bridging back:

* **Trivial bridging back** implicitly converts ``NSArray`` to
  ``[AnyObject]`` in O(1) plus the cost of calling ``copy()`` on
  the ``NSArray``. [#nocopy]_

* **Implicit conversions** between ``Array`` types

  - **Implicit upcasting** implicitly converts ``[Derived]`` to
    ``[Base]`` in O(1).
  - **Implicit bridging** implicitly converts ``[X]`` to
    ``[X._ObjectiveCType]`` in O(N).

  .. Note:: Either type of implicit conversion may be combined with
     `trivial bridging`_ in an implicit conversion to ``NSArray``.

* **Checked conversions** convert ``[T]`` to ``[U]?`` in O(N)
  via ``a as [U]``.

  - **Checked downcasting** converts ``[Base]`` to ``[Derived]?``.
  - **Checked bridging back** converts ``[T]`` to ``[X]?`` where
    ``X._ObjectiveCType`` is ``T`` or a trivial subtype thereof.

* **Forced conversions** convert ``[AnyObject]`` or ``NSArray`` to
  ``[T]`` implicitly, in bridging thunks between Swift and Objective-C.

  For example, when a user writes a Swift method taking ``[NSView]``,
  it is exposed to Objective-C as a method taking ``NSArray``, which
  is force-converted to ``[NSView]`` when called from Objective-C.

  - **Forced downcasting** converts ``[AnyObject]`` to ``[Derived]`` in
    O(1)
  - **Forced bridging back** converts ``[AnyObject]`` to ``[X]`` in O(N).

  A forced conversion where any element fails to convert is considered
  a user programming error that may trap.  In the case of forced
  downcasts, the trap may be deferred_ to the point where an offending
  element is accessed.

.. Note:: Both checked and forced downcasts may be combined with `trivial
          bridging back`_ in conversions from ``NSArray``.

Maintaining Type-Safety
:::::::::::::::::::::::

Both upcasts and forced downcasts raise type-safety issues.

Upcasts
.......

TODO: this section is outdated.

When up-casting an ``[Derived]`` to ``[Base]``, a buffer of
``Derived`` object can simply be ``unsafeBitCast``\ 'ed to a buffer
of elements of type ``Base``—as long as the resulting buffer is never
mutated.  For example, we cannot allow a ``Base`` element to be
inserted in the buffer, because the buffer's destructor will destroy
the elements with the (incorrect) static presumption that they have
``Derived`` type.

Furthermore, we can't (logically) copy the buffer just prior to
mutation, since the ``[Base]`` may be copied prior to mutation,
and our shared subscript assignment semantics imply that all copies
must observe its subscript assignments.

Therefore, converting ``[T]`` to ``[U]`` is akin to
resizing: the new ``Array`` becomes logically independent.  To avoid
an immediate O(N) conversion cost, and preserve shared subscript
assignment semantics, we use a layer of indirection in the data
structure.  Further, when ``T`` is a subclass of ``U``, the
intermediate object is marked to prevent in-place mutation of the
buffer; it will be copied upon its first mutation:

.. image:: ArrayCast.png

.. _deferred:

Deferred Checking for Forced Downcasts
.......................................

In forced downcasts, if any element fails to have dynamic type ``Derived``,
it is considered a programming error that may cause a trap.  Sometimes
we can do this check in O(1) because the source holds a known buffer
type.  Rather than incur O(N) checking for the other cases, the new
intermediate object is marked for deferred checking, and all element
accesses through that object are dynamically typechecked, with a trap
upon failure (except in ``-Ounchecked`` builds).

When the resulting array is later up-cast (other than to a type that
can be validated in O(1) by checking the type of the underlying
buffer), the result is also marked for deferred checking.

----

.. [#nocopy] This ``copy()`` may amount to a retain if the ``NSArray``
   is already known to be immutable.  We could eventually optimize out
   the copy if we can detect that the ``NSArray`` is uniquely
   referenced.  Our current unique-reference detection applies only to
   Swift objects, though.