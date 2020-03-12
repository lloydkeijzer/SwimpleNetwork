import XCTest
import Alamofire
@testable import SwimpleNetwork

final class SwimpleNetworkTests: XCTestCase {
    
    func testCreatable() {
        // Given
        Mocked.response(
            withMockedData: MockedResponse.createProduct.data,
            andStatusCode: MockedResponse.createProduct.statusCode
        )
        
        let expectation = XCTestExpectation(description: "Creates a product")
        
        // When
        let product = ProductEntity(title: "Product")
        product.create(usingMockedSession: true) { (result) in
            switch result {
            case .success(_):
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }
    
    func testRequestable() {
        // Given
        Mocked.response(
            withMockedData: MockedResponse.getProduct.data,
            andStatusCode: MockedResponse.getProduct.statusCode
        )
        
        let expectation = XCTestExpectation(description: "Gets a product")
        
        // When
        ProductEntity.get(id: "1", usingMockedSession: true) { (result) in
            switch result {
            case .success(let product):
                XCTAssertEqual(product.title, "Product")
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }
    
    func testUpdatable() {
        // Given
        Mocked.response(
            withMockedData: MockedResponse.updateProduct.data,
            andStatusCode: MockedResponse.updateProduct.statusCode
        )
        
        let expectation = XCTestExpectation(description: "Updates a product")
        
        // When
        var product = ProductEntity(id: "1", title: "Product")
        product.title = "Updated Product"
        product.update(usingMockedSession: true) { (result) in
            switch result {
            case .success(let product):
                XCTAssertEqual(product.title, "Updated Product")
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }
    
    func testRemovable() {
        // Given
        Mocked.response(withStatusCode: 200)
        
        let expectation = XCTestExpectation(description: "Removes a product")
        
        // When
        let product = ProductEntity(id: "1", title: "Product")
        product.delete(usingMockedSession: true) { (result) in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }
    
    func testUploadable() {
        // Given
        let testImageFilePath = "image.png"
        FileManager.default.createFile(
            atPath: testImageFilePath,
            contents: "fake image".data(using: .utf8),
            attributes: nil
        )
        
        Mocked.response(
            withMockedData: MockedResponse.uploadProductImage.data,
            andStatusCode: MockedResponse.uploadProductImage.statusCode
        )
        
        let expectation = XCTestExpectation(description: "Uploads a product image")
        
        // When
        var product = ProductEntity(
            id: "1",
            image: testImageFilePath,
            title: "Product"
        )
        
        if let uploadableImage = product.uploadableImage {
            XCTAssertEqual(product.resourceURL, URL(string: "http://any.com/products/1"))
            
            let completion: ResultCompletion<ImageURLEntity, AFError> = { result in
                switch result {
                case .success(let response):
                    if let fileURL = response.image {
                        product.uploadableImage?.fileURL = fileURL
                        expectation.fulfill()
                    } else {
                        XCTFail()
                    }
                case .failure(_):
                    XCTFail()
                }
            }
            
            uploadableImage.upload(
                to: product.resourceURL,
                usingMockedSession: true
            ).responseDecodable { (response) in
                completion(response.result)
            }
        } else {
            XCTFail()
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
        
        try? FileManager.default.removeItem(atPath: testImageFilePath)
    }
    
    func testWrappedCRUDableEntities() {
        // Given
        Mocked.response(
            withMockedData: MockedResponse.wrappedProducts.data,
            andStatusCode: MockedResponse.wrappedProducts.statusCode
        )
        
        let expectation = XCTestExpectation(description: "Get wrapped products")
        
        // When
        WrappedProductsEntity.get(usingMockedSession: true) { (result) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.products.count, 3)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }
    
    func testURLRequestAuthenticator() {
        // Given
        Mocked.response(withStatusCode: 401)
        
        URLRequestAuthenticator.shared.refreshTokenDataRequest = Mocked.AF.request("http://any.com", method: .get)
        
        let expectation = XCTestExpectation(description: "Authenticates request")
        
        // When
        WrappedProductsEntity.get(usingMockedSession: true) { (result) in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.products.count, 3)
                expectation.fulfill()
            case .failure(_):
                XCTFail()
            }
        }
        
        // Then
        wait(for: [expectation], timeout: 3)
    }

    static var allTests = [
        ("testCreatable", testCreatable),
        ("testRequestable", testRequestable),
        ("testUpdatable", testUpdatable),
        ("testUploadable", testUploadable),
        ("testWrappedCRUDableEntities", testWrappedCRUDableEntities),
        ("testURLRequestAuthenticator", testURLRequestAuthenticator)
    ]
}
