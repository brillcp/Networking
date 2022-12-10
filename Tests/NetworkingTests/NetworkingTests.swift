import XCTest
import Combine
@testable import Networking

final class NetworkingTests: XCTestCase {

    private let serverConfig = ServerConfig(baseURL: "https://reqres.in/api")
    private lazy var networkService = Network.Service(server: serverConfig)
    private var cancel: AnyCancellable?

    func testMockUser() throws {
        let user = MockGetRequest.user(1)
        let expectation = expectation(description: "Awaiting mock user")

        cancel = try networkService.request(user).sink { (result: Result<MockUserResponse, Error>) in
            expectation.fulfill()
            switch result {
            case .success(let user): XCTAssertTrue(user.data.id == 1)
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 30.0)
    }

    func testMockUsers() throws {
        let users = MockGetRequest.users
        let expectation = expectation(description: "Awaiting mock users")

        cancel = try networkService.request(users).sink { (result: Result<MockUsersRepsonse, Error>) in
            expectation.fulfill()
            switch result {
            case .success(let user): XCTAssertTrue(!user.data.isEmpty)
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 30.0)
    }

    func testMockPostUser() throws {
        let model = MockPostUserModel(name: "Viktor", job: "iOS Engineer")
        let users = MockPostRequest.user(model)
        let expectation = expectation(description: "Awaiting mock post users")

        cancel = try networkService.responsePublisher(users).sink { result in
            expectation.fulfill()
            switch result {
            case .success(let responseCode): XCTAssertTrue(responseCode == .created)
            case .failure(let error): XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 30.0)
    }

    func testDownloadImageFile() {
        let url = "https://media.viktorgidlof.com/2022/12/djunglehorse.jpg".asURL()
        let expectation = expectation(description: "Awaiting image download progress")

        cancel = networkService.downloadPublisher(url: url).sink { result in
            switch result {
            case .success(.destination(let url)):
                expectation.fulfill()
                XCTAssertTrue(url.lastPathComponent.split(separator: ".").last == "tmp")
            case .success(.progress(let progress)):
                print("Download progress: \(progress)")
            case .failure(let error):
                expectation.fulfill()
                XCTFail(error.localizedDescription)
            }
        }
        waitForExpectations(timeout: 30.0)
    }
}
