//
//  ViewController.swift
//  GoodbyeCOVID19
//
//  Created by BH on 2021/10/24.
//

import UIKit
import Charts
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var totalCaseLabel: UILabel!
    @IBOutlet weak var newCaseLabel: UILabel!
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchCovidOverview { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(result):
                debugPrint("success \(result)")
            
            case let .failure(error):
                debugPrint("error \(error)")
            }
            
        }
    }

    func fetchCovidOverview(
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = ["serviceKey": "JWYD1Apxaz3ZvbFKcVe56ouOisRkmLX9n"] // 발급받은 key
        
        AF
            .request(url, method: .get, parameters: param)
            .responseData { response in
                switch response.result {
                case let .success(data):
                    do {
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(CityCovidOverview.self, from: data)
                        completionHandler(.success(result))
                    } catch {
                        completionHandler(.failure(error))
                    }
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            }
    }

}

