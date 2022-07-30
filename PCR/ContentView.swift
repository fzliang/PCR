//
//  ContentView.swift
//  PCR
//
//  Created by fengzhiliang on 2022/7/24.
//

import SwiftUI

struct ContentView: View {
    private var currentNotificationCenter = UNUserNotificationCenter.current()
    @State private var hint:String = "明天"
    @State private var nextPRCDate:DateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: Date())
    
    
    var body: some View {
        VStack {
            Text("你 \(hint) 该去做核酸了").fontWeight(.bold).font(.title).foregroundColor(.red)
            
            Text("下次做核酸的日期👉\(nextPRCDate.month!)月\(nextPRCDate.day!)日👈").foregroundColor(.gray)
            
            Button("😎 我今天做了") {
                onTap(days: 0)
            }.buttonStyle(.borderedProminent).padding(.top, 10)
            
            Button("🤔 我昨天做了") {
                onTap(days: 1)
            }.buttonStyle(.borderedProminent).padding(.top, 10)
            
            Button("😷 我前天做了") {
                onTap(days: 2)
            }.buttonStyle(.borderedProminent).padding(.top, 10)
            
            Button("😮‍💨 别找了你今天该去了") {
                onTap(days: 3)
            }.foregroundColor(.red).padding(.top, 10)
            
            Button("😓 要不还是去健康宝看看吧") {
                let urlStr = "alipays://platformapi/startapp?appId=2021001135679870".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                if let url = URL(string: urlStr!) {
                    UIApplication.shared.open(url)
                }
                
            }.padding(.top, 5)
        }.onAppear() {
            resetNextPRCDate()
        }
    }
    
    func resetNextPRCDate() {
        currentNotificationCenter.getPendingNotificationRequests { (requests) in
            for request in requests {
                print(request)
                if let trigger  = request.trigger as? UNCalendarNotificationTrigger {
                    nextPRCDate = trigger.dateComponents
                    
                    let today = getDateComponentsAfterDays(days: 0);
                    if (today.month == nextPRCDate.month
                        && today.day == nextPRCDate.day) {
                        hint = "今天"
                        return
                    }
                    let tomorrow = getDateComponentsAfterDays(days: 1);
                    if (tomorrow.month == nextPRCDate.month
                        && tomorrow.day == nextPRCDate.day) {
                        hint = "明天"
                        return
                    }
                    let theDayAfterTomorrow = getDateComponentsAfterDays(days: 2);
                    if (theDayAfterTomorrow.month == nextPRCDate.month
                        && theDayAfterTomorrow.day == nextPRCDate.day) {
                        hint = "后天"
                        return
                    }
                    hint = "\(nextPRCDate.month!)月\(nextPRCDate.day!)日"
                    return
                }
            }
        }
    }
    
    func getDateComponentsAfterDays(days: Int) -> DateComponents {
        var newDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        newDate = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: newDate!)
        
        let date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: newDate!)
        
        return date
    }
    
    func onTap(days: Int) {
        if (days == 0) {
            clearNotify()
            notify(days: 3, hour: 17, minute: 30)
        } else if (days == 1) {
            clearNotify()
            notify(days: 2, hour: 17, minute: 30)
        } else if (days == 2) {
            clearNotify()
            notify(days: 1,hour: 17, minute: 30)
        } else if (days == 3) {
            clearNotify()
            notify(days: 0, hour: 17, minute: 30)
        }
    }
    
    func clearNotify() {
        currentNotificationCenter.removeAllPendingNotificationRequests();
        currentNotificationCenter.removeAllDeliveredNotifications();
    }
    
    func notify(days: Int, hour: Int, minute: Int) {
       
        var newDate = Calendar.current.date(byAdding: .day, value: days, to: Date())
        newDate = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: newDate!)
        
        let date = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: newDate!)
        
        let identifier = "pcr \(hour) \(minute)"
        
        let content = UNMutableNotificationContent()
        content.title = "做核酸了"
        content.body = "今天\(date.month!)月\(date.day!)日,该去做核酸了！！！"
//        content.sound = .default
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "happy.caf"));
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false);

        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        currentNotificationCenter.add(request) { error in
            if let error = error {
                print(error)
            }
            resetNextPRCDate()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
