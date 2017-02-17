//
//  StripeVaporBackendAdapter.swift
//  instacrate-ios
//
//  Created by Hakon Hanesand on 2/11/17.
//  Copyright © 2017 Instacrate. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

extension Request {
    
    static private let emptyDataStatusCodes: Set<Int> = [204, 205]
    
    public static func nativeSerializeResponseJSON(response: HTTPURLResponse?, data: Data?, error: Error?) -> Result<JSON> {
        guard error == nil else { return .failure(error!) }
        
        if let response = response, emptyDataStatusCodes.contains(response.statusCode) { return .success(JSON(Node.null)) }
        
        guard let validData = data, validData.count > 0 else {
            return .failure(AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
        }
        
        do {
            let json = try JSON(serialized: [UInt8](validData))
            return .success(json)
        } catch {
            return .failure(AFError.responseSerializationFailed(reason: .jsonSerializationFailed(error: error)))
        }
    }
}

extension DataRequest {
    
    public static func nativeJSONResponseSerializer() -> DataResponseSerializer<JSON> {
        return DataResponseSerializer { _, response, data, error in
            return Request.nativeSerializeResponseJSON(response: response, data: data, error: error)
        }
    }
    
    @discardableResult
    public func nativeResponseJSON(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<JSON>) -> Void) -> Self {
        return response(
            queue: queue,
            responseSerializer: DataRequest.nativeJSONResponseSerializer(),
            completionHandler: completionHandler
        )
    }
}

final class StripeVaporBackendAdapter: NSObject, STPBackendAPIAdapter {
    
    func retrieveCustomer(_ completion: @escaping STPCustomerCompletionBlock) {
        Alamofire.request("http://api.instacrate.me/customers/", parameters: ["type[]": "stripe"]).responseJSON { response in
            guard let value = response.result.value as? NSDictionary else {
                return
            }
            
            guard let stripeData = value["stripe"] else {
                fatalError("No stripe field from our server.")
            }
            
            let serializer = STPCustomerDeserializer(jsonResponse: stripeData)
            
            guard let customer = serializer.customer else {
                fatalError("Error parsing customer from server.")
            }
            
            completion(customer, nil)
        }
    }
    
    func attachSource(toCustomer source: STPSource, completion: @escaping STPErrorBlock) {
        Alamofire.request("http://api.instacrate.me/customers/sources/\(source.stripeID)", method: .post).nativeResponseJSON { response in
            completion(response.result.error)
        }
    }
    
    func selectDefaultCustomerSource(_ source: STPSource, completion: @escaping STPErrorBlock) {
        Alamofire.request("http://api.instacrate.me/customers/sources/default/\(source.stripeID)", method: .post).nativeResponseJSON { response in
            completion(response.result.error)
        }
    }
}
