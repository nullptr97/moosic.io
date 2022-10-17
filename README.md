# moosic.io API (VK Music, Boom)
[![Build Status](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

##### moosic.io призвана упростить использование API ВК Музыки для iOS

## Преймущества

- Прямая авторизация через ВК (посредством логина и пароля)
- Поддержка обработки капчи и подтверждения входа
- Запросы к API moosic.io
- На выбор два типа обращений к АПИ (Decodable/Parseable)

## Настройка
 - Создайте файл делегата ***Delegate.swift
 
 ```swift
import Foundation
import MoosicIO

class ***Delegate: NSObject, MoosicIODelegate {
    override init() {
        super.init()
        
        MoosicIO.setup(delegate: self)
    }
    
    func vkNeedsScopes(for sessionId: String) -> String {
        return "all"
    }
    
    func tokenRemoved(for sessionId: String) {
        print("Token removed in session: \(sessionId)")
    }
    
    func tokenCreated(for sessionId: String, token: String) {
        print("Token created in session: \(sessionId)")
    }
}
```
 - В AppDelegate.swift создайте переменную delegate: MoosicIODelegate?
 ```swift
 var delegate: MoosicIODelegate?
 ```
 - В методе `func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool`
 
 ```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    delegate = ***Delegate()
    /* your code */
    return true
}
```
## Авторизация
`Три метода авторизации`
 
 ```swift
func login(login: String, password: String) async throws // обычная авторизация
func login(login: String, password: String, captchaSid: String?, captchaKey: String?) async throws // авторизация с капчей
func login(login: String, password: String, code: Int?, forceSms: Int) async throws // авторизация с двухфакторной защитой
```

## Использование API-методов

##### - Decodable
##### ‎ 
 ```swift
Task {
    do {
        let response = try await DecodableApi<Model>.exec("playlist/4465163384/tracks/", dataField: "tracks", parameters: ["limit": "2"], requestMethod: .get)
        print(response)
    } catch {
        print(error)
    }
}
```

##### - Parsable
##### ‎ 
 ```swift
Task {
    do {
        let response = try await Api<Response<ParseableModel>>.exec("playlist/4465163384/tracks/", dataField: "tracks", parameters: ["limit": "2"], requestMethod: .get)
        print(response)
    } catch {
        print(error)
    }
}
```

* Данный метод предназначен для ручного парсинга данных (Parseable)

```swift
struct Cover: Parseable {
    let accentColor, avgColor: String?
    let url: URL?
    
    static func parse(_ json: JSON) -> Cover {
        let cover = Cover(accentColor: json["accentColor"].string,
                          avgColor: json["avgColor"].string,
                          url: URL(string: json["url"].stringValue))
        return cover
    }
}
```

## Выход из аккаунта
`Выйти из аккаунта можно двумя способами`
 
 ```swift
func logout() // простой выход
func logout(_ block: @escaping () -> (Void)) // выход с последующим действием
```
