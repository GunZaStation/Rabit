# Rabit

<div align="center">


![제목 없는 디자인-5](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040069.png)

<img src="https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210011633745.png" alt="Habit-2" width="15%;" />

> 생활 습관 관리🐰📝, Rabit
>
> 🗓2022.07.19 ~ ing

</div>

## 🧑🏻‍💻 개발인원

| Jed                                   | Sol                                     |
| ------------------------------------- | --------------------------------------- |
| [이준우](https://github.com/junu0516) | [김한솔](https://github.com/Hansolkkim) |



## ⭐️ 프로젝트 소개

달성 목표를 생성해 일정 시간마다 알림을 받을 수 있습니다.

사진을 찍어 목표 달성을 인증할 수 있습니다.



## ⚙️ 개발 환경 및 라이브러리

[![swift](https://img.shields.io/badge/Swift-5.0-critical?style=plastic&logo=Swift)]() [![xcode](https://img.shields.io/badge/Xcode-13.4-blue?style=plastic&logo=Xcode)]() [![rxswift](https://img.shields.io/badge/RxSwift-6.5-purple?style=plastic&logo=ReactiveX)]()

[![snapkit](https://img.shields.io/badge/SnapKit-5.6-469DB8?style=plastic)]()  [![Realm](https://img.shields.io/badge/Realm-10.20-39477F?style=plastic&logo=Realm)]()

<img src="https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040974.jpg" alt="SS2022-10-01PM04.57.16" width="40%;" />



## 👀 미리보기

| ![카테고리추가화면](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040960.gif) | ![목표추가화면](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040801.gif) | ![날짜선택](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040311.gif) | ![알림시간설정](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040902.gif) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|                     `목표 카테고리 생성`                     |                         `목표 생성`                          |                   `목표의 진행 날짜 지정`                    |                   `목표의 알림 시간 지정`                    |

| ![촬영화면](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040865.gif) | ![앨범](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210312040843.gif) | ![앨범사진수정](https://raw.githubusercontent.com/Hansolkkim/Image-Upload/forUpload/img/202210252304135.gif) |
| :----------------------------------------------------------: | :----------------------------------------------------------: | :----------------------------------------------------------: |
|                    `목표 인증 사진 촬영`                     |                    `목표 인증 사진 앨범`                     |                  `목표 인증 사진 속성 변경`                  |



## 🏛 아키텍처

위키로 이동하는 링크? or 사진 추가?

### Why MVVM + C?

<details>
    <summary>Click Me</summary>

- **기존의 MVC 구조의 한계를 극복하고자 ViewModel 개념을 적용한 MVVM 패턴을 도입**


    - 다양한 모델(Entity)을 뷰컨트롤러에서 관리해야 하는데, 이럴 경우 UIViewController 내에 화면의 입출력 관리 및 모델 관리에 대한 책임이 모두 존재하기 때문에 결과적으로 크기가 너무 커지는 문제점이 있습니다.
    
    ```swift
    final class MyViewController: UIViewController {
    
    	//화면 출력에 사용될 모델 타입 배열을 뷰컨트롤러가 속성으로 가짐		
    	private var myModels: [MyModel]
    		
    	override func viewDidLoad() {
    		super.viewDidLoad()
    
    		//모델 타입 배열을 초기화
    		initModels()
    
    		//사용자에게 보여질 화면을 초기화
    		initViews()
    	}	
    
    	private func initViews() {
    		//서브뷰, 배경색 등 뷰를 그리는 로직을 명시
    	}
    
    	private func initModels() {
    		//모델 타입 배열을 초기화하는 로직을 명시
    	}
    }
    ```


    - 기본적인 MVC 구조를 채택할 경우 위와 같이 Controller 내부에는 View와의 소통을 통한 입출력 관리, View의 출력에 대응되는 Model을 관리하는 책임을 모두 가지게 됩니다.
    - 프로젝트의 크기가 커질수록 위의 2가지 책임의 크기도 커지기 때문에 결과적으로 Controller이 지나치게 커지는 문제점이 있습니다.
    - 이러한 한계를 극복하고자 MVVM 패턴을 도입하여 UIViewController 타입의 책임을 상대적으로 가볍게 하고자 했습니다.
- **뷰컨트롤러가 가지는 화면 전환에 대한 책임을 분리하고자 Coordinator 패턴을 도입**
    - MVVM 패턴을 이용해 비교적 가벼운 ViewController를 만들었으나, MVVM 중 **View**에 속하는 ViewController가 맡아야하는 화면 전환에 대한 책임 또한 View의 역할을 벗어난다고 판단했습니다.
    - 따라서 Coordinator 패턴을 도입하여 ViewController가 가지고 있던 “화면 전환 책임”을 Coordinator 객체가 갖도록 했습니다.
      
        ```swift
        protocol Coordinator: AnyObject {
            
            var parentCoordiantor: Coordinator? { get set }
            var children: [Coordinator] { get }
            var navigationController: UINavigationController { get }
            
            func start()
        }
        ```
        
    - Coordinator 객체는 위의 프로토콜을 채택하고 있습니다.
      
        모든 Coordinator는 `children` , 즉 자식 Coordinator를 가지고 있도록 하고, 자식 Coordinator에게 자신의 navigationController를 넘겨주도록 했습니다.
        
        또한 모든 Coordinator는 `parent` , 즉 부모 Coordinator를 알고 있도록 하여, 자식 Coordinator가 사라질 때 부모 Coordinator에게 이를 알릴 수 있도록 했습니다.
        
        그리고 `start()` 메소드를 구현하여, 부모 Coordinator가 자식 Coordinator를 생성한 후  `start()` 메소드를 호출할 수 있도록 하여, 제일 처음 처리해야할 로직을 `start()` 메소드 내에 구현하도록 했습니다.
        
    - 그리고 추가적으로 ViewModel <-> Coordinator 간의 정보를 주고 받기 위한 용도로 Navigation 프로토콜을 Coordinator 객체가 채택하도록 했습니다.
      
        ```swift
        <예시>
        protocol ColorSelectNavigation {
        	var closeColorSelectView: PublishRelay<Void>
        }
        
        final class AlbumCoordinator: Coordinator, ColorSelectNavigation {
        	func bind() {
        		closeColorSelectView
        	    .bind(onNext: dismissColorSelectView)
        	    .disposed(by: disposeBag)
        	}
        
        	private func dismissColorSelectView() {
        		// ColorSelectView를 닫는 로직
        	}
        }
        
        final class ColorSelectViewModel {
        	init(navigation: ColorSelectNavigation) {
        		bind(navigation: navigation)
        	}
        
        	func bind(navigation: ColorSelectNavigation) {
        		closeColorSelectRequested
        	    .bind(to: navigation.closeColorSelectView)
        	    .disposed(by: disposeBag)
        	}
        }
        ```
        
    - 위처럼 ColorSelectView를 닫는 로직은 Coordinator가 갖고 있어야 하고, 이 로직을 ColorSelectViewModel이 알고 있을 필요가 없습니다.
      
        하지만 이를 구현하기 위해서는 ColorSelectViewModel이 **더 상위 모듈**인 AlbumCoordinator를 알고 있어야하는 문제가 발생합니다.
        
        이 문제를 극복하기 위해 ColorSelectViewModel 초기화 생성자에 ColorSelectNavigation을 매개변수로 받아, ColorSelectView를 닫아야함을 ViewModel이 Coordinator에게 알려주기 위한 용도로 Navigation 프로토콜 내의 속성을 사용하도록 했습니다. 
        
        (ViewModel이 Coordinator를 알고 있지 않도록 하기 위해 ViewModel이 따로 프로퍼티로 Navigation 타입, 즉 Coordinator를 저장하지 않습니다.)
      </details>



### Why RxSwift?
<details>
    <summary>Click Me</summary>

- MVVM 패턴에서 ViewModel, View(ViewController) 간의 데이터 바인딩을 더욱 깔끔하게 하기 위해 도입했습니다.

- RxSwift를 사용하지 않고도 NotificationCenter 혹은 Custom Observable 구현 등을 통해 데이터 바인딩을 할 수 있지만, 많은 경우가 코드가 여러 곳에 분산되기 때문에 그만큼 가독성이 떨어지는 문제가 있었습니다.

- RxSwift를 사용할 경우에는 대부분의 경우 하나의 메소드 내에 Observable 타입의 구독을 위한 로직을 모아놓고 관리할 수 있기 때문에, 그만큼 팀원들 간에 서로의 코드를 이해하기가 수월할 뿐만 아니라 바인딩 로직만 보고도 UI가 어떤 흐름으로 업데이트되는 지 예측하기가 상대적으로 쉬웠습니다.

- 추가로 RxCocoa, RxGesture 등을 사용할 경우 UIControl, UIPanGestureRecognizer 등을 사용할 때 이벤트 발생에 따른 로직 처리나, 버튼의 터치 혹은 UITextField에서의 문자열값 업데이트 등을 코드 작성 및 리팩토링에 용이하게 처리할 수 있었습니다.

- 다만, RxSwift 자체를 학습하기 위한 비용이 크고, 제공되는 여러 Subject 타입과 다양한 Observable 생성 및 구독 방식을 놓고 어느 것을 선택할 지 고민하고 논의하는 시간이 길었지만 그만큼 커뮤니케이션 과정에서 Observable의 동작원리와 여러 Subject의 실제 상황에서의 사용 목적 등에 대해 깊게 생각할 수 있어서 유익했다고 생각합니다.
</details>


### Why RxDataSources?
<details>
    <summary>Click Me</summary>

- 가장 큰 이유는, UICollectionView에 <u>기존의기존의 RxSwift만 사용해서는 여러 Section을 가지는 UICollectionView를 다룰 수 없었기 때문</u>에 RxDataSources를 채택하기로 결정했습니다.
- 해당 문제는 UIViewController를 **UICollectionViewDataSource** 프로토콜을 채택함으로써도 해결할 수 있었지만, UICollectionViewDataSource 프로토콜을 채택한 UIViewController는 MVVM에서의 View 역할에 벗어난다고 판단했고,
  
    RxDataSources를 사용할 경우 UIViewController가 View 역할을 벗어나지 않을 수도 있고, 해당 프로토콜을 채택해 구현해야하는 메소드를 사용할 때보다 코드를 보다 간결하게 작성할 수 있었습니다.
    
    ```swift
    // UICollectionViewDataSource 프로토콜을 사용할 경우
    class someViewController: UIVIewController, UICollectionViewDataSource {
    
    	let someCollectionView: UICollectionView
    	let dataSource: UICollectionViewDataSource
    
    	override func viewDidLoad() {
    		super.viewDidLoad()
    		self.someCollectionView.dataSource = self
    	}
    
    	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    		...
    	}
    	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    		...
    	}
    }
    
    // RxDataSources를 채택한 경우
    class someViewController: UICollectionView {
    	let someCollectionView: UICollectionView
    	let dataSource: RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<Album, Photo>>
    
    	func bind() {
    		viewModel.albumData
    			.bind(to: albumCollectionView.rx.items(dataSource: dataSource)
    	}
    }
    ```
    
- 또한 RxDataSources가 제공하는 기능 중에 **DataSource의 변경을 계산해서 변경된 DataSource에 해당하는 Cell만 리로드해주는 기능**이 있었고, 해당 기능을 사용하면 같은 기능을 사용하기 위해 작성해야하는 코드를 생략할 수도 있어 보다 깔끔한 바인딩 로직을 구현할 수 있기 때문에 RxDataSources를 채택했습니다.

</details>


### Why Realm?
<details>
    <summary>Click Me</summary>

- 서버와의 네트워크 통신 없이 동작하는 앱을 구현하고자 했기 때문에, Persistence Layer을 구성해야 했습니다.
- 앱 실행에 필요한 여러 객체 데이터를 영구적으로 저장하고자 Realm, CoreData, SQLite 등의 선택지를 놓고 고민했고 최종적으로 Realm을 사용했습니다.
- 현재는 아래와 같이 ReamManager을 구현해놓고, 상태를 가지지 않는 싱글톤 객체의 형태로 사용하고 있습니다.
    <details>
        <summary>Realm Manager 코드</summary>


    ```swift
    import Foundation
    import RealmSwift
    
    final class RealmManager {
        
        private let realm: Realm
        static var shared = RealmManager()
        
        private init() {
            self.realm = try! Realm()
        }
        
        func read<T: Object>(entity: T.Type, filter query: String? = nil) -> [T] {
            if let query = query {
                return realm.objects(entity).filter(query).toArray(ofType: entity)
            } else {
                return realm.objects(entity).toArray(ofType: entity)
            }
        }
     
        func write(entity: Object) throws {
            try? realm.write {
                realm.add(entity)
            }
        }
    
        func update<T: Object>(entity: T) throws {
            try? realm.write {
                realm.add(entity, update: .modified)
            }
        }
    }
    ```
    
    </details>

- Realm에 대해 지속적으로 학습하면서 추후 아래와 같은 방향으로 RealmManager 개선하고자 합니다.
    - Realm에 대한 읽기/쓰기 작업은 메인 스레드가 아닌 다른 백그라운드 스레드에서 수행해야
    - Realm은 기본적으로 Thread-Safe하게 설계되있지 않기 때문에, 임계영역을 설정하고자 하면 별도의 Serial Queue를 Realm Manager에서 내부적으로 사용하도록 처리
    - 서로 다른 스레드 간에 Realm으로부터 가져온 Entity를 전달하는 경우가 있는 지 살펴보기
        - 그럴 경우에는 스레드 간의 데이터 전송을 위해 별도로 또 처리해야 함
        - Realm은 데이터베이스 자체에 대한 인스턴스나, 다른 객체 혹은 collection에 대해서 기본적으로 Thread-Confined하게 설계되있기 때문
        </details>

        
        
## 🛠 트러블슈팅

### 공통

- [ViewController/ViewModel이 자신의 Coordinator 객체를 알고 있어야 할까?](https://github.com/GunZaStation/Rabit/wiki/Trouble-Shooting#viewcontrollerviewmodel이-자신의-coordinator-객체를-알고-있어야할까)
  
- [ViewModel 간의 데이터 전달](https://github.com/GunZaStation/Rabit/wiki/Trouble-Shooting#viewmodel-간의-데이터-전달)


### 김한솔(Sol)


- [CollectionView Cell의 포커싱 효과로 UX 개선에 대한 고민 해결](https://github.com/GunZaStation/Rabit/wiki/Trouble-Shooting#collectionview-cell의-포커싱-효과로-ux-개선에-대한-고민-해결)
  
- [share 오퍼레이터 활용에 대한 고민](https://github.com/GunZaStation/Rabit/wiki/Trouble-Shooting#share-오퍼레이터-활용에-대한-고민)
  
- [이미지와 메모리 최적화에 대한 고민](https://github.com/GunZaStation/Rabit/wiki/Trouble-Shooting#이미지와-메모리-최적화에-대한-고민)
