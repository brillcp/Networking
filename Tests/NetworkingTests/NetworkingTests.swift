import XCTest
import Combine
@testable import Networking

final class NetworkingTests: XCTestCase {

    private var cancel: AnyCancellable?

    func testGitHubUser() throws {
        let serverConfig = ServerConfig(baseURL: "https://api.github.com")
        let networkService = Network.Service(server: serverConfig)
        let user = TestRequest.user("brillcp")
        let expectation = expectation(description: "Awaiting GitHub user")

        cancel = try networkService.request(user).sink { (result: Result<TestUser, Error>) in
            expectation.fulfill()
            switch result {
            case .success(let user):
                XCTAssertTrue(user.name == "Viktor G")
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 30.0)
    }
}
