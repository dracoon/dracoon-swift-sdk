//
//  RateLimitInterceptor.swift
//  dracoon-sdk
//
//  Created by Mathias Schreiner on 05.07.21.
//  Copyright © 2021 Dracoon. All rights reserved.
//

import Foundation
import Alamofire

/// - Tag: RateLimitInterceptor
public protocol RateLimitInterceptor : RequestInterceptor {
    func setRateLimitAppliedDelegate(_ delegate: RateLimitAppliedDelegate?)
    func restoreExpirationDate(_ date: Date)
}

class RateLimitManager: RateLimitInterceptor, @unchecked Sendable {
    
    private let dispatchQueue = DispatchQueue(label: "com.dracoon.rateLimitManager")
    
    private weak var delegate: RateLimitAppliedDelegate?
    
    func setRateLimitAppliedDelegate(_ delegate: RateLimitAppliedDelegate?) {
        self.dispatchQueue.sync {
            self.delegate = delegate
        }
    }
    
    func restoreExpirationDate(_ date: Date) {
        if let existingTimer = self.timer, existingTimer.isValid {
            return
        }
        let difference = date.timeIntervalSince(Date())
        if difference > 0, Int(difference) <= DracoonConstants.MAX_429_WAITING_TRESHOLD_SECONDS {
            let waitingTimeSeconds = difference.rounded(.up)
            self.startTimer(timeInterval: waitingTimeSeconds)
        }
    }
    
    typealias AdaptRequestCompletion = (Result<URLRequest, Error>) -> Void
    private var requestsToSend: [URLRequest:AdaptRequestCompletion] = [:]
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let existingTimer = self.timer, existingTimer.isValid else {
            completion(.success(urlRequest))
            return
        }
        self.requestsToSend[urlRequest] = completion
    }
    
    typealias RequestRetryCompletion = (RetryResult) -> Void
    private var requestsToRetry: [RequestRetryCompletion] = []
    private var timer: Timer?
    private let lock = NSRecursiveLock()
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let waitingTimeSeconds = self.checkTooManyRequestsResponse(error, request: request) else {
            completion(.doNotRetry)
            return
        }
        if request.retryCount < 3 {
            self.requestsToRetry.append(completion)
        } else {
            completion(.doNotRetry)
        }
        self.dispatchQueue.sync {
            self.delegate?.rateLimitApplied(expirationDate: Date(timeIntervalSinceNow: TimeInterval(waitingTimeSeconds)))
        }
        
        // prevents other failed requests to simultaneously start a timer
        lock.lock()
        defer {
            lock.unlock()
        }
        self.startTimer(timeInterval: TimeInterval(waitingTimeSeconds))
    }
    
    private func startTimer(timeInterval: TimeInterval) {
        DispatchQueue.main.async {
            if let existingTimer = self.timer, existingTimer.isValid {
                existingTimer.invalidate()
            }
            
            let timer = Timer(timeInterval: timeInterval, repeats: false, block: { [weak self] t in
                t.invalidate()
                self?.retryRequests()
                self?.sendQueuedRequests()
            })
            timer.tolerance = 0.5
            self.timer = timer
            RunLoop.current.add(timer, forMode: .default)
        }
    }
    
    private func retryRequests() {
        self.requestsToRetry.forEach { $0(.retry) }
        self.requestsToRetry.removeAll()
    }
    
    private func sendQueuedRequests() {
        self.requestsToSend.forEach({$0.value(.success($0.key))})
        self.requestsToSend.removeAll()
    }
    
    private func checkTooManyRequestsResponse(_ error: Error, request: Request) -> Int? {
        if let response = request.response, response.statusCode == DracoonErrorParser.HTTPStatusCode.TOO_MANY_REQUESTS {
            if let waitingTimeSecondsString = response.allHeaderFields["Retry-After"] as? String,
               let waitingTimeSeconds = Int(waitingTimeSecondsString) {
                return waitingTimeSeconds
            } else {
                return DracoonConstants.DEFAULT_429_WAITING_TIME_SECONDS
            }
        }
        return nil
    }
}
