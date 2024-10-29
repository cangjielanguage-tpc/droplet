/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2024. All rights resvered.
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
                    Button("TestJpg").onClick {Router.push(url:  "TestJpg")}
                    Button("TestPng").onClick {Router.push(url:  "TestPng")}
                    Button("TestWebp").onClick {Router.push(url: "TestWebp")}
                    Button("TestBmp").onClick {Router.push(url:  "TestBmp")}
                }.width(100.percent)
            }
        }.height(100.percent)
    }
}
