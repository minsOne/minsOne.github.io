---
layout: post
title: "translate Keychain Services Concepts"
description: ""
category: ""
tags: []
---
{% include JB/setup %}

# Keychain Services Concepts 키체인 서비스 개념

Computer users typically manage multiple accounts that require logins with user IDs and passwords. Secure FTP servers, AppleShare servers, database servers, secure websites, instant messaging accounts, and many other services require authentication. Users often respond by making up very simple, easily remembered passwords, by using the same password over and over, or by writing passwords down where they can be easily found. Any of these behaviors compromises security.

컴퓨터 사용자는 일반적으로 유저 아이디와 비밀번호로 로그인이 필요한 다중 계정을 관리합니다. 보안 FTP 서버, AppleShare 서버, 데이터베이스 서버, 보안 웹사이트, 인스턴트 메시징 계정 그리고 다른 많은 서비스들은 인증이 필요합니다. 유저는 종종 매우 간단하고 기억하기 쉬운 비밀번호를 만들거나, 같은 암호를 반복해서 사용하거나, 쉽게 찾을 수 있는 곳에 암호를 쓰는 방식으로 합니다. 이러한 동작 중 어느것이든 보안을 위태롭게 합니다.

The Keychain Services API provides a solution to this problem. By making a single call to this API, an app can store small bits of secret information on a keychain, from which the app can later retrieve the information—also with a single call. The keychain secures data by encrypting it before storing it in the file system, relieving you of the need to implement complicated encryption algorithms. The system also carefully controls access to stored items. The entire keychain can be locked, meaning no one can decrypt its protected contents until it is unlocked with a master password. Even with an unlocked keychain, the system’s Keychain Access policy ensures that only authorized apps gain access to a given item in the keychain. In the simplest case, the app that created an item is the only one that can access it later. However, Keychain Services also provides ways to share secrets among apps.

키체인 서비스 API는 이 문제의 해결책을 제공합니다. API를 한 번 호출하면, 앱은 키체인에 비밀 정보의 작은 비트(?)로 저장을 하며, 앱은 나중에 한번 호출로 정보를 검색할 수 있습니다. 키체인 보안 데이터는 파일 시스템에 저장되기 전에 암호되며, 복잡한 암호화 알고리즘을 구현할 필요성을 덜어줍니다. 또한 저장된 아이템에 접근을 신중하게 제어합니다. 전체 키체인이 잠길 수 있는데, 마스터 비밀번호로 풀 때까지 보호된 컨텐츠를 해독할 수 없습니다. 심지어 잠금 해제 된 키체인이더라도, 시스템의 키체인 접근 정책은 인증된 앱만 키체인에 아이템을 접근해서 가져오도록 보장합니다. 간단한 경우로, 아이템을 만든 앱만 나중에 접근할 수 있습니다. 그러나 키체인 서비스는 앱 간에 비밀을 공유하는 방법을 제공합니다.

From the user’s point of view, a keychain provides transparent authentication; that is, (after unlocking the keychain) the user does not have to log in separately to any services whose passwords are stored in the keychain. These can be retrieved later without prompting the user. This means that users can have arbitrarily complex and variable passwords without having to worrying about committing them to memory, or recording them in an insecure location. Figure 1-1 shows the relationship between the user, the keychain, and the password-protected services.

사용자 관점에서 볼 때, 키체인은 투명한 인증을 제공합니다. 즉, (키체인이 해제된 후에) 사용자는 키체인에 암호가 저장된 서비스에 별도로 로그인 할 필요가 없습니다. 나중에 사용자에게 묻지 않고 검색할 수 있습니다. 즉, 사용자는 메모리에 커밋하거나 안전하지 못한 위치에 기록할 필요없이 임의적으로 복잡하고 가변적인 비밀번호를 가질 수 있습니다. Figure 1-1는 사용자, 키체인 그리고 암호로 보호된 서비스 간의 관계를 보여줍니다.

In addition to passwords, keychains also store cryptographic keys, certificates, and (in macOS) text strings (notes). For more information about creating and managing keys and certificates in particular, see Certificate, Key, and Trust Services Programming Guide.

키체인은 비밀번호 외에도, 암호 키, 인증서 및 (macOS에서) 텍스트 문자열 (메모)를 저장합니다. 키와 인증서를 만들고 관리하는 방법은 [인증서, 키 및 Trust 서비스 프로그래밍 가이드](https://developer.apple.com/library/content/documentation/Security/Conceptual/CertKeyTrustProgGuide/index.html#//apple_ref/doc/uid/TP40001358)를 참고하세요.



# Structure of a Keychain 키체인 구조

In practical terms, a keychain is simply a database stored in the file system. By default, in macOS, each login account has one keychain (for a new account on macOS 10.3 or later, this keychain is named login.keychain). However, a user or application can create as many keychains as desired. An iOS device, on the other hand, has a single keychain that is available to all apps. In addition, when a user logs into an iCloud account on a device, the system provides a logically distinct iCloud keychain.

실질적으로 키체인은 단순히 파일 시스템에 저장된 데이터베이스입니다. 기본적으로 macOS에서 각 로그인 계정은 하나의 키체인을 가지고 있습니다(macOS 10.3 이상에서 새 계정은 키체인 이름이 login.keychain입니다). 그러나 사용자 또는 어플리케이션은 원하는 만큼 많은 키체인을 만들 수 있습니다. 반면 iOS 기기에서는 단일 키체인을 가지며 모든 앱이 사용할 수 있습니다. 또한 사용자가 기기에서 iCloud 계정으로 로그인하면, 시스템은 논리적으로 구별하는 iClode 키체인을 제공합니다.

A keychain holds any number of keychain items, each of which is composed of data plus a set of attributes. The attributes associated with a keychain item depend on the class of the item. Some attributes, such as the creation date and a label, are common to all item classes. Others are specific to the class. For example, the generic password class includes service and account name attributes. The Internet password item class, on the other hand, includes attributes for such things as the server, the security domain, the protocol type, and a path, as well as the account name.

키체인은 여러 키체인 아이템을 가지며, 각 키체인 아이템은 데이터와 속성 집합으로 구성되어 있습니다. 키체인 아이템과 연관된 속성은 아이템의 클래스에 따라 달라집니다. 생성 날짜 및 레이블과 같은 일부 속성은 모든 아이템 클래스에 공통됩니다. 다른 것들은 클래스에 한정됩니다. 예를 들면, 일반 암호 클래스는 서비스와 계정 이름 속성을 포함합니다. 반면 인터넷 암호 아이템 클래스는 서버, 보안 도메인, 프로토콜 타입 및 경로 뿐만 아니라 계정 이름과 같은 것들이 속성에 포함됩니다.

Items marked as synchronizable using the kSecAttrSynchronizable attribute, are placed in the iCloud keychain, which is automatically synchronized among all other instances of the same user’s iCloud keychains on other devices through the network.

kSecAttrSynchronizable 속성을 사용하여 동기화 가능한 것으로 표시된 아이템은 네트워크를 통해 다른 기기에서 같은 사용자의 iCloud 키체인의 모든 다른 인스턴스 간에 자동으로 동기화되는 iCloud 키체인에 위치합니다.

For a keychain item that needs protection, such as a password or private key (a short and secret string of bytes, used in asymmetric cryptography), the data is encrypted and protected by the keychain. For keychain items that do not need protection, such as certificates, the data is not encrypted. Encrypted data is inaccessible when the keychain is locked. In macOS, if you try to access encrypted data while the keychain is locked, Keychain Services displays a dialog prompting the user for the keychain password. In iOS, the keychain is automatically unlocked when the devices is unlocked, so your application always has access to its own keychain item data while the user is present.

암호 또는 비밀 키(비대칭 암호화에서 사용되는 짧은 비밀 바이트 문자열)와 같은 보호가 필요한 키체인 항목에서 데이터는 키체인으로 암호화되고 보호됩니다. 인증서와 같이 보호가 필요하지 않은 키체인 아이템의 경우 데이터는 암호화되지 않습니다. 키체인이 잠겨있으면 암호화된 데이터는 접근할 수 없습니다. macOS에서는 키체인이 잠겨있는 동안 암호화된 데이터를 접근하려고 하면, 키체인 서비스는 키체인 비밀번호를 묻는 다이얼로그를 표시합니다. iOS에서는 키체인은 기기가 풀려 있을 때 자동으로 풀려지며, 사용자가 있는 동안 어플리케이션은 항상 자신의 키체인 아이템 데이터에 접근할 수 있습니다.

Note: Unlike data, an item’s attributes are not considered secret, and thus never encrypted. They can be read at any time, even when the keychain is locked.
In macOS, for items not synchronized through iCloud, each protected keychain item (and the keychain itself) additionally contains access control information in the form of an opaque data structure called an access object. The access object contains one or more access control list (ACL) entries for that item. Each ACL entry has a list of one or more authorization tags specifying operations that can be done with that item, such as decrypting or authenticating. In addition, each ACL entry has a list of trusted applications that can perform the specified operations without authorization from the user. For more information about ACLs, read Access Control Lists.

주의 : 데이터와 달리 키체인 아이템의 속성은 비밀로 간주되지 않기에 암호화되지 않습니다. 속성은 키체인이 잠겨있어도 언제든지 읽을 수 있습니다.
macOS에서는 iCloud를 통해 동기화되지 않은 아이템은 각 보호된 키체인 아이템( 및 키체인 자체)은 액세스 객체(access object)라는 불투명한 데이터 구조의 형태로 접근 제어 정보를 추가로 포함합니다. 액세스 객체는 해당 항목에 대한 하나 이상의 접근 제어 목록(ACL) 항목이 있습니다. 각 ACL 항목은 작업 복호화나 인증과 같은 작업을 수행할 수 있는 작업을 지정하는 하나 이상의 인증 태그 목록이 있습니다. 또한 각 ACL 항목은 사용자 인증없이 지정된 작업을 수행할 수 있는 신뢰할 수 있는 어플리케이션 목록이 있습니다. ACL 관련한 자세한 정보는 [Access Control List](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html#//apple_ref/doc/uid/TP30000897-CH204-CJBIBIBC)를 참고하세요.

Accessing a Keychain

In macOS, the login keychain is automatically unlocked during login if it has the same password as the user’s login account password. When first created, the login keychain is also the default keychain. The default keychain is used to store newly created keychain items unless a different keychain is specified in the function call; 

certain other Keychain Services functions also use the default keychain when no other keychain is specified. The user can use the Keychain Access utility to designate another keychain as the default; however, the login keychain doesn’t change.

macOS에서 로그인 키체인은 사용자 로그인 계정 비밀번호와 동일한 비밀번호를 가지고 있으면 로그인 중에 자동으로 잠금 해제 됩니다. 처음 만들어질 때, 로그인 키체인은 기본 키체인이기도 합니다. 기본 키체인은 함수 호출에서 다른 키체인이 지정되지 않는 경우 새로 생성된 키체인 아이템을 저장하는데 사용됩니다. 특정 키체인 서비스는 다른 키체인이 지정되지 않을 때 기본 키체인을 사용합니다. 사용자는 Keychain Access Utility를 사용하여 다른 키체인을 기본값으로 지정할 수 있습니다. 그러나 로그인 키체인은 변경되지 않습니다.

In iOS, the situation is simpler: There is a single keychain accessible to applications (which encompasses the logically distinct iCloud keychain). This keychain is automatically unlocked when the user unlocks the device, and then locked when the device is locked. An application can access only its own keychain items, or those shared with a group to which the app belongs.

iOS에서는 더 간단한 상황입니다. 어플리케이션(논리적으로 구별되는 iCloud 키체인을 포함하는)에 접근할 수 있는 단일 키체인이 있습니다. 이 키체인은 사용자가 기기를 잠금 해제할 때 자동으로 잠금 해제되고, 기기를 잠글 때 키체인도 잠깁니다. 어플리케이션은 소유한 키체인 항목 또는 앱이 속한 그룹이 공유하는 항목에만 접근할 수 있습니다.

### Use High Level Functions For Basic Keychain Access 기본 키체인 접근을 위한 고수준 함수 사용

Although the structure of the keychain provides a great deal of power and flexibility, it also introduces a certain level of complexity. Fortunately, the Keychain Services API provides a handful of high-level functions that handle common keychain operations that apps typically need.

키체인 구조는 많은 권한과 유연성을 제공하지만, 일정 수준의 복잡성을 가져옵니다. 키체인 서비스 API는 앱에서 필요한 일반적인 키체인 작업을 처리하는 몇 가지 고수준 함수를 제공합니다.

Note: iOS and the macOS iCloud keychain do not offer the functions described in this section. To perform the same set of tasks in these cases, you step down one level in the API, as described in Use Lower Level Functions When You Need More Control.


주의: iOS와 macOS iCloud 키체인은 이 부분에서 설명하지 않습니다. 이 경우에서 동일한 작업들을 수행하려면, [더 많은 제어가 필요할 때 저수준 기능 사용](https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/02concepts/concepts.html#//apple_ref/doc/uid/TP30000897-CH204-SW2)에 기술된 바와 같이 API에서 한단계 아래로 내려갑니다.

In macOS, to create a password item and add it to a keychain, you call one of two functions, depending on whether you want to add an Internet password or some other type of password: SecKeychainAddInternetPassword or SecKeychainAddGenericPassword. For example, to add a generic password, you might say:

macOS에서 비밀번호 항목 생성과 이를 키체인에 추가하려면, 인터넷 암호나 다른 유형의 비밀번호(SecKeychainAddInternetPassword 또는 SecKeychainAddGenericPassword)를 추가할지에 따라 두가지 기능 중 하나를 호출합니다. 예를 들면, 일반 비밀번호를 추가하려면 다음과 같이 호출합니다.

```
NSString* service = @"myService";
NSString* account = @"username";
NSString* password = @"somethingSecret";
const void* passwordData = [[password dataUsingEncoding:NSUTF8StringEncoding] bytes];
 
OSStatus status = SecKeychainAddGenericPassword(
                      NULL,        // 기본 키체인 사용 Use default keychain
                      (UInt32)service.length,
                      [service UTF8String],
                      (UInt32)account.length,
                      [account UTF8String],
                      (UInt32)password.length,
                      passwordData,
                      NULL         // 항목 참조하지 않음
                  );
 
if (status != errSecSuccess) {     // 항상 상태를 확인
    NSLog(@"Write failed: %@", SecCopyErrorMessageString(status, NULL));
}
```

When you pass NULL for the keychain reference, the system adds the item to the default keychain. The system also returns an optional reference to the newly created keychain item through the last argument. If you do not need the item reference, pass NULL for this argument, as shown above. The add function also creates the access object for you, listing the calling application as the only trusted application by default.

키체인 참조에 NULL을 전달하면, 시스템은 기본 키체인에 항목을 추가합니다.

You check if the operation succeeds by examining the return status. One reason the call might fail, for example, is if the user fails to unlock a locked keychain. If the keychain is locked when this or any other keychain access call is made, the system automatically prompts the user for the keychain password, as shown in Figure 1-2. But if the user cancels or is otherwise unable to unlock the keychain, the add operation fails with an appropriate status result.

Figure 1-2  Prompting the user to unlock the keychain

Later, to read back the stored item, use SecKeychainFindInternetPassword or SecKeychainFindGenericPassword. Again, for a generic password:

UInt32 pwLength = 0;
void* pwData = NULL;
SecKeychainItemRef itemRef = NULL;
 
OSStatus status = SecKeychainFindGenericPassword(
                      NULL,         // Search default keychains
                      (UInt32)service.length,
                      [service UTF8String],
                      (UInt32)account.length,
                      [account UTF8String],
                      &pwLength,
                      &pwData,
                      &itemRef      // Get a reference this time
                  );
 
if (status == errSecSuccess) {
    NSData* data = [NSData dataWithBytes:pwData length:pwLength];
    NSString* password = [[NSString alloc] initWithData:data
                                               encoding:NSUTF8StringEncoding];
    NSLog(@"Read password %@", password);
} else {
    NSLog(@"Read failed: %@", SecCopyErrorMessageString(status, NULL));
}
 
if (pwData) SecKeychainItemFreeContent(NULL, pwData);  // Free memory
If you make this call from the same app that created the item, Keychain Services automatically grants access because the app is in the item’s ACL. If you make this call from a different app, Keychain Services prompts the user for permission to access the item, as shown in Figure 1-3. The user can either Deny, Allow (just this once), or Always Allow. In the latter case, the system adds the new app to the ACL for the item, and does not prompt the user in the future for this item from this app.

Figure 1-3  Prompting the user to allow access to a keychain item

Passing NULL for the keychain parameter on a find tells the system to search for items in the default keychain search list. This is the same as the keychain list in the Keychain Access utility. The item reference in the above call also could have been NULL, as in the add operation, if you only want the password data, which appears in its own output parameter. However, in preparation for the next example, you obtain a reference to the complete keychain item by supplying a reference pointer.

Be sure to free the memory of the password data after using it, as shown at the end of the example above. You are also responsible for freeing the memory associated with the item reference, but not yet, since it is used in the next example, which shows how to modify the item.

To modify an existing keychain item, use SecKeychainItemModifyAttributesAndData. Test whether an item already exists by trying to read it, as in the above code. If the return status on a read operation indicates success, and in particular is not errSecItemNotFound, then the item exists on the keychain. In this case, trying to add an item with the same service and account would fail with the errSecDuplicateItem status. Instead, use the item reference obtained during the read operation to modify the item, as below. Don’t forget to free the memory indicated by the item reference when you are done with it:

OSStatus status = SecKeychainItemModifyAttributesAndData(
                      itemRef,                 // From the read
                      NULL,                    // Attributes unchanged
                      (UInt32)password.length, // As before
                      passwordData
                  );
 
if (status != errSecSuccess) {
    NSLog(@"Update failed: %@", SecCopyErrorMessageString(status, NULL));
}
 
if (itemRef) CFRelease(itemRef);   // Now, free the item reference memory
macOS Keychain Services Tasks contains further examples of how to use these functions in your application.

Note: While not an exact corollary, starting in iOS 8, the SecAddSharedWebCredential and SecRequestSharedWebCredential functions, working in concert with a particular web site that is configured appropriately, allow you to store and retrieve credentials for that web site in a way that is also shared with Safari. To learn more about the Shared Web Credentials API, read Shared Web Credentials Reference.
Use Lower Level Functions When You Need More Control
To perform more general operations on keychain items, Keychain Services provides a family of general purpose access functions:

Use SecItemAdd to create a new keychain item.
Use SecItemCopyMatching to retrieve a keychain item’s attributes and/or data.
Use SecItemUpdate to modify a keychain item in place.
Use SecItemDelete to remove a keychain item.
Each function takes as a first argument a dictionary of key-value pairs to specify the attributes of the keychain item that you want to add or access. For functions other than SecItemAdd, this dictionary may also contain search criteria. When used for search, the dictionary typically contains:

The class key-value pair, which specifies the class of items (for example, Internet passwords or cryptographic keys) for which to search.
One or more key-value pairs that specify the attribute data (such as label or creation date) to be matched.
One or more search key-value pairs, which specify values that further refine the search, such as a limit on the number of search results, or whether string matching should be case-sensitive.
A return-type key-value pair, specifying the type of results you want (for example, a dictionary or a persistent reference).
The set of valid attributes depends on the class of the item for which you wish to search. For example, if you specify a value of kSecClassGenericPassword for the kSecClass key, then you can specify values for creation date and modification date, but not for subject or issuer (which are used with certificates).

As an example, if you wanted to perform a case-insensitive search for the password for an Apple Store account with the account name of “ImaUser”, you could use the following dictionary with the SecItemCopyMatching function:

Type of key
Key
Value
Item class
kSecClass
kSecClassGenericPassword
Attribute
kSecAttrAccount
"ImaUser"
Attribute
kSecAttrService
"Apple Store"
Search attribute
kSecMatchCaseInsensitive
kCFBooleanTrue
Return type
kSecReturnData
kCFBooleanTrue
The kSecReturnData key causes the function to place the keychain item’s data—in this case, the password—in the result parameter, a reference to which is given as the function’s second argument. If instead you want a dictionary of attributes (so you can determine, for example, the creation date of the item), you use the kSecReturnAttributes return-type key with a value of kCFBooleanTrue.

In all cases, these functions return a status code, indicating what, if anything, went wrong.

Take Advantage of Advanced Features on macOS for Manipulating Keychains
Keychain Services on macOS automatically interacts with the user on behalf of you app under certain circumstances. For example, the section Use High Level Functions For Basic Keychain Access shows the system’s default behavior when you attempt to access a keychain that is locked, or a keychain item for which your app is not authorized.

In addition, the macOS Keychain Services API provides functions that allow you to programmatically create new keychains, manipulate elements within a keychain in more sophisticated ways, and manage collections of keychains. For example, in macOS, your app can:

Disable or enable Keychain Services functions that display a user interface; for example, a server might want to suppress the Unlock Keychain dialog box and unlock the keychain itself instead.
Unlock a locked keychain when the user is unable to do so, as for an unattended server.
Add trusted applications to the access object of a keychain item if, for example, a server application wants to let an administration application have access to its passwords.
Register a callback function so that your application is called when a keychain event (such as unlocking the keychain) occurs.
However, these functions are generally needed only by programs designed specifically to administer keychains. macOS includes a keychain administration program, called Keychain Access (Figure 1-4). With this utility, a user can lock or unlock keychains, create new keychains, change the default keychain, add and delete keychain items, change the values of the attributes of keychain items, and see or change the data stored in a keychain item.

Figure 1-4  The Keychain Access application

Sharing Keychain Items

In addition to globally locking and unlocking the entire keychain at appropriate times, the system also restricts which apps can access specific keychain items. By default, an app that creates an item, and only that app, can read it back or modify it. However, sometimes you want to share a secret among apps. How you do this depends on the situation.

Access Groups
In iOS, and in macOS when using the iCloud keychain (for items with the kSecAttrSynchronizable attribute set to kCFBooleanTrue), you share keychain items using Access Groups. This kind of sharing does not require interaction with, or permission from the user, but limits sharing to apps that are delivered by a single development team.

Note: This form of keychain item sharing is not available to macOS apps when they are not using the iCloud keychain. For sharing in that environment, use Access Control Lists instead.
From a high level perspective, Keychain Services uses an app’s code signature with its embedded entitlements to ensure that only an authorized app can access a particular keychain item. By default, only the app that created an item can access it in the future. But Keychain Services does more than simply check the identity of an app. Instead, it compares a keychain item’s access group, recorded as the kSecAttrAccessGroup attribute, with the list of access groups to which an app belongs. If one of the app’s access groups matches the keychain item’s group, access is granted. Similarly, Keychain Services allows an app to create keychain items with the kSecAttrAccessGroup attribute set to any of the app’s own access groups.

Access groups are represented as strings, stored in an app’s entitlements, and prefixed with a team identifier (the unique character sequence issued by Apple to each development team). Because code signing seals the entitlements, and because your signing identity includes your team identifier, an app’s access groups cannot be tampered with, and your app can only belong to groups specific to your development team. For more information about the mechanics of code signing, read Code Signing Guide.

The actual list of access groups to which an app belongs is the array of strings formed as the concatenation of the following app entitlements, taken in this order:

Keychain Access Groups. The keychain-access-groups entitlement holds an array of strings. Each string names an access group. This entitlement is optional.
The Application Identifier. Xcode automatically adds the application-identifier entitlement to every app during code signing. This string is formed as the team identifier plus the bundle identifier. For details about the bundle identifier, read Configuring Identity and Team Settings in App Distribution Guide.
The string contained in this entitlement is always present, and is therefore the default application group when you do not define a keychain-access-groups entitlement. In other words, all apps belong at least to this one group, of which it is the only member.

Application Groups. When you collect related apps into an application group using the application-groups entitlement, they share access to a group container, and gain the ability to message each other in certain ways, as described in Adding an App to an App Group. Starting is iOS 8, the array of strings given by this entitlement also extends the list of keychain access groups.
Note: An app with a minimum deployment target earlier than iOS 8.0 cannot use application groups for keychain item sharing, and should instead rely on the keychain-access-groups entitlement to share keychain items.
When your app creates a keychain item, if you do not explicitly specify the kSecAttrAccessGroup key in the item’s attributes dictionary, Keychain Services uses the first group of the app’s access groups array (ordered as shown above) as the default access group. If your app has a keychain-access-groups entitlement, Keychain Services uses the first of these. Otherwise, it uses the application identifier, which is always present. Thus, by default, unless you add a keychain-access-groups entitlement, an app creates keychain items to which only it has access. On the other hand, all the named access groups from the collection above are valid values for the kSecAttrAccessGroup key. This allows you to add new items to any one of the app’s groups.

Going in the other direction, when searching for a keychain item (whether to modify, delete, or simply read it), Keychain Services grants access to all items with an access group matching any one of your app’s access groups.

Important: If your app attempts to add a keychain item using an access group to which the app does not belong, the operation fails. This includes attempts to "prime” an entry using a zero-length string as the value for the kSecAttrAccessGroup key, since the empty string represents an invalid group.
As a concrete example, consider a development group at the Acme company with the team identifier 659823F3DC that publishes two apps: AppNumberOne and AppNumberTwo. The corresponding application identifiers might be:

659823F3DC.com.Acme.AppNumberOne
659823F3DC.com.Acme.AppNumberTwo
By default, keychain items created by these apps are not accessible to each other, or to any other app, because each is effectively in its own group, as specified by the application identifier.

However, suppose both apps add a keychain-access-groups entitlement with a single entry. The entry in each app’s the entitlement file looks like:

<key>keychain-access-groups</key>
<array>
    <string>659823F3DC.com.Acme.GroupStorage</string>
</array>
Then both apps would add new keychain items to that access group by default and both applications would have access to keychain items in that group. In addition, each application still has access to its own private keychain items: AppNumberOne has access to items in keychain access group 659823F3DC.com.Acme.AppNumberOne and AppNumberTwo has access to items in 659823F3DC.com.Acme.AppNumberTwo. Further, both apps can continue to store new private items by specifying their own application identifier as the value associated with the kSecAttrAccessGroup key in the attributes dictionary during an add operation.

Access Control Lists
In macOS, for items not stored on the iCloud keychain, you share keychain items by manipulating an item’s Access Control Lists. This sharing mechanism allows apps to grant other apps access to their own keychain items, including to apps from other developers. In addition, it provides a means for Keychain Services, after prompting for user permission, to arbitrarily expand the list of apps authorized for a particular action.

Note: Access Control Lists are not available in iOS or to macOS apps that use the iCloud keychain. For keychain item sharing in those environments, use Access Groups instead.
When a macOS app attempts to access a secret keychain item, the system looks at each ACL entry for that item to determine whether the application should be allowed access. If there is no ACL entry for that operation, then access is denied and it is up to the calling application to try something else or to notify the user. If there are any ACL entries for the operation, then the system looks at the list of trusted applications of each ACL entry to see if the calling application is in the list. If it is—or if the ACL specifies that all applications are allowed access—then access is permitted without confirmation from the user (as long as the keychain is unlocked). If there is an ACL entry for the operation but the calling application is not in the list of trusted applications, then the system prompts the user for the keychain password before permitting the application to access the item.

The Keychain Services API provides functions to create, delete, read, and modify ACL entries. Because an ACL entry is always associated with an access object, when you modify an ACL entry, you are modifying the access object as well. Therefore, there is no need for a separate function to write a modified ACL entry back into the access object.

An access object may contain any number of ACL entries. Evaluation order is unpredictable when two or more ACL entries are for the same operation.

Trusted Applications

An ACL entry either permits all applications to perform the operations specified by its list of authorization tags or it contains a list of trusted applications. The trusted application list is actually a list of trusted application objects (objects with the opaque type SecTrustedApplicationRef). In addition to serving as a reference to the application, a trusted application object includes data that uniquely identifies the application, such as a cryptographic hash. The system can use this data to verify that the application has not been altered since the trusted application object was created. For example, when a trusted application requests access to an item in the keychain, the system checks this data before granting access. Although you can extract this data from the trusted application object for storage or for transmittal to another location (such as over a network), this data is in a private format; there is no supported way to read or interpret it.

You can use the SecTrustedApplicationCreateFromPath function to create a trusted application object. The trusted application is the binary form of the application that’s on the disk at the moment the trusted application object is created. If an application listed as a trusted application for a keychain item is modified in any way, the system does not recognize it as a trusted application. Instead, the user is prompted for confirmation when that application attempts to access the keychain item.

When a program attempts to access a keychain item for which it is not recognized as a trusted application, the system displays a confirmation dialog (Figure 1-5). The confirmation dialog has three buttons: Deny, Allow, and Always Allow. If the user clicks Always Allow, the system creates a trusted application object for the application and adds it to the access object for that keychain item.

Figure 1-5  Application access confirmation dialog

To make the launching of programs more efficient, the system prebinds executables to dynamically loaded libraries (DLLs). When a user updates a DLL, the system automatically changes the executables of all the programs that use that library, a process referred to as reprebinding. Reprebinding a trusted application therefore causes the application to no longer match the version represented in the application hash. In OS X 10.2 and earlier, the next time the application tries to use a protected keychain item, a confirmation dialog appears. When the user clicks Always Allow, the system adds it to the access object as a new trusted application. Starting with macOS 10.3, on the other hand, the system maintains a database that keeps track of applications that were reprebound so that in most cases no confirmation dialog appears.

ACL Entries

The SecAccessCreate function creates an access object with three ACL entries. The first, referred to as owner access, determines who can modify the access object itself. By default, there are no trusted applications for owner access; the user is always prompted for permission if someone tries to change access controls. The second ACL entry is for operations considered safe, such as encrypting data. This ACL entry applies to all applications. The third ACL entry is for operations that should be restricted, such as decrypting, signing, deriving keys, and exporting keys. This ACL entry applies to the trusted applications listed as input to the function.

In addition to providing a list of trusted applications to SecAccessCreate, you specify a CFString that describes the keychain item. This is the name of the item that appears in dialogs (see Figure 1-5 for example). This is not necessarily the same name as appears for the item in the Keychain Access utility.

You use other functions in Keychain Services to modify any of these default ACL entries or to add additional ACL entries to the access object (see Keychain Services Reference). These functions let you retrieve all the ACL entries for an access object, modify ACL entries, and create new ones. For each ACL entry, you can specify trusted applications, the item descriptor string, a list of authorization tags, and a prompt selector bit. If you set the prompt selector bit, the user is prompted for the keychain password each time a non-trusted application attempts to access the item, even if the keychain is already unlocked. Figure 1-6 shows the dialog; compare this figure with Figure 1-5, which is the dialog that appears if the prompt selector bit is not set. If the user clicks Always Allow in response to this dialog, the application is added to the access object as a trusted application and the dialog does not appear again. This bit is clear by default—you must set it explicitly for any ACL entry for which you want this extra protection. There is one exception to this rule: the Keychain Access application always requires a password to display the secret of a keychain item unless the Keychain Access application itself is included in the trusted application list.

Figure 1-6  Unlock keychain dialog to confirm access

As noted earlier, because an ACL entry is always associated with an access object, when you modify an ACL entry, you are modifying the access object as well. Therefore, there is no need for a separate function to write a modified ACL entry back into the access object. However, if you modify an access object, you must write the new version of the access object to the keychain item before the keychain item can use it.

Securing Keychain Data

The keychain is designed to provide straightforward access to secure storage with minimal effort on the part of either developers or users. Nevertheless, there are some best practices to be aware of when using the keychain.

Keychain Accessibility
On an iOS device, the keychain is automatically locked when the device is locked, and unlocked when the user unlocks the device. Therefore it is important to set a passcode on your device, and keep it secret.

In macOS, to provide security for the passwords and other valuable secrets stored in your keychain, adopt at least the following measures:

Set your keychain to lock itself when not in use. In the Keychain Access utility, choose Edit > Change Settings for Keychain, and check both Lock checkboxes.
Use a different password for your keychain than your login password. In Keychain Access utility, choose Edit > Change Password to change your keychain's password. Click the lock icon in the Change Password dialog to get the password assistant, which tells you how secure your password is and can suggest passwords. Be sure to pick one you can remember—don't write it down anywhere.
When a user backs up an iOS device to iTunes or iCloud, the keychain data is included in the backup, but the secret data in the keychain remain encrypted. The keychain password is not included in the backup. The passwords and other secrets stored in the keychain can only be extracted from a backup by restoring it to a device, and unlocking the device with the same passcode the user set before making the backup. This makes the keychain the safest place to persistently store a user’s secret data.

Keychain Item Accessibility
Keychain Services additionally gives you programmatic control over individual item accessibility using the kSecAttrAccessible attribute across two dimensions. On the first dimension, you control item availability relative to the locked state of the device. In order of decreasing restrictiveness, the choices are:

When Passcode Set. If the user has not set a passcode, items cannot be stored with this setting. If the user removes the passcode from a device, any items with this setting are deleted from the keychain. Items with this setting can only be accessed if the device is unlocked. Use this setting if your app only needs access to items while running in the foreground.
When Unlocked. Items with this setting are only accessible when the device is unlocked. A device without a passcode is considered to always be unlocked. This is the default accessibility when you do not specify the kSecAttrAccessible attribute for a keychain item.
After First Unlock. This condition becomes true once the user unlocks the device for the first time after a restart, or if the device does not have a passcode. It remains true until the device restarts again. Use this level of accessibility when your app needs to access the item while running in the background.
Always. The item is always accessible, regardless of the locked state of the device. This option is not recommended.
The second dimension of item accessibility determines whether the item migrates to a new device when a backup is restored. If the item’s kSecAttrAccessible attributes ends with the string ThisDeviceOnly, the item is restored to the same device that created a backup, but it is not migrated to a new device when restoring another device’s backup data.

Important: Always use the most restrictive option that makes sense for your app. For apps running entirely in the foreground, them most secure option is kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly. If your app must access keychain items while running in the background, the most secure option is kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly.
