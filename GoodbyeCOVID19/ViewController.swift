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
                self.configureStackView(koreaCovidOverView: result.korea)
                let covidOverviewList = self.makeCovidOverviewList(cityCovidOverview: result)
                self.configureChartView(covidOverviewList: covidOverviewList)
                print(self.makeCovidOverviewList(cityCovidOverview: result))
                
            case let .failure(error):
                debugPrint("error \(error)")
            }
            
        }
    }
    
    func makeCovidOverviewList(cityCovidOverview: CityCovidOverview) -> [CovidOverview] {
        return [
            cityCovidOverview.seoul,
            cityCovidOverview.busan,
            cityCovidOverview.chungbuk,
            cityCovidOverview.chungnam,
            cityCovidOverview.daegu,
            cityCovidOverview.daejeon,
            cityCovidOverview.gangwon,
            cityCovidOverview.gwangju,
            cityCovidOverview.gyeongbuk,
            cityCovidOverview.gyeonggi,
            cityCovidOverview.gyeongnam,
            cityCovidOverview.incheon,
            cityCovidOverview.jeju,
            cityCovidOverview.jeonbuk,
            cityCovidOverview.jeonnam,
            cityCovidOverview.sejong,
            cityCovidOverview.ulsan
        ]
    }
    
    func configureChartView(covidOverviewList: [CovidOverview]) {
        let entries = covidOverviewList.compactMap { [weak self] overview -> PieChartDataEntry? in
            guard let self = self else { return nil }
            return PieChartDataEntry(
                value: self.removeFormatString(string: overview.newCase),
                label: overview.countryName, // PieChart??? ????????? ??????
                data: overview
            )
        }
        let dataSet = PieChartDataSet(entries: entries, label: "????????? ?????? ??????")
        // ?????? ???????????? ??????
        dataSet.sliceSpace = 1 // ??????
        dataSet.entryLabelColor = .black // label ?????????
        dataSet.xValuePosition = .outsideSlice // ?????? ????????? ???????????? ????????????
        dataSet.valueLinePart1OffsetPercentage = 0.8
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.3
        dataSet.colors = ChartColorTemplates.vordiplom() +
            ChartColorTemplates.joyful() +
            ChartColorTemplates.liberty() +
            ChartColorTemplates.pastel() +
            ChartColorTemplates.material()
        dataSet.valueTextColor = .black // ???????????? ?????????
        
        self.pieChartView.data = PieChartData(dataSet: dataSet)
        self.pieChartView.spin(duration: 0.2, fromAngle: self.pieChartView.rotationAngle, toAngle: self.pieChartView.rotationAngle + 80)
    }
    
    func removeFormatString(string: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal // decimal ? ??????
        return formatter.number(from: string)?.doubleValue ?? 0
    }
    func configureStackView(koreaCovidOverView: CovidOverview) {
        self.totalCaseLabel.text = "\(koreaCovidOverView.totalCase) ???"
        self.newCaseLabel.text = "\(koreaCovidOverView.newCase) ???"
    }
    
    func fetchCovidOverview(
        completionHandler: @escaping (Result<CityCovidOverview, Error>) -> Void
    ) {
        let url = "https://api.corona-19.kr/korea/country/new/"
        let param = ["serviceKey": "JWYD1Apxaz3ZvbFKcVe56ouOisRkmLX9n"] // ???????????? key
        
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

