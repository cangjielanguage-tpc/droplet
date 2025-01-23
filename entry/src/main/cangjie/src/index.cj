/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights reserved.
 */

package ohos_app_cangjie_entry

import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*

import ohos.base.*
import ohos.ability.*
import ohos.window.*
import ohos.router.*

@Entry
@Component
class MyView {
    let scroller = Scroller()

    func build() {
        Row {
            Scroll(this.scroller){
                Column {
                    Button("Index_LLT").onClick {Router.push(url: "Index_LLT")}

                     Divider().color(0x000000).strokeWidth(1).margin(top: 10, bottom: 10)

                    // L0
//                    Button("Index_L0").onClick {Router.push(url:  "Index_L0")}
//                    Divider().color(0x000000).strokeWidth(1).margin(top: 10, bottom: 10)

                    // L1
//                    Button("Index_L1").onClick {Router.push(url:  "Index_L1")}
//                    Divider().color(0x000000).strokeWidth(1).margin(top: 10, bottom: 10)

                    // L2
//                    Button("Index_L2").onClick {Router.push(url:  "Index_L2")}
//                    Divider().color(0x000000).strokeWidth(1).margin(top: 10, bottom: 10)

                }.width(100.percent)
            }
        }.height(100.percent)
    }
}
