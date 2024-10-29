/**
 * Created on 2024/7/29
 */
package ohos_app_cangjie_entry

import ohos.component.*
import ohos.state_manage.*
import ohos.state_macro_manage.*
import ohos.base.*
import ohos.ability.*
import cj_res_entry.app
import droplet.droplet.*
import ohos.router.*

@Entry
@Component
class TestWebp {
    @State
    var text: String = ""

    @State
    var textTmp: String = ""

    @State
    var option: DropletRequestOption = DropletRequestOption(
        loadSrc: "https://img2.baidu.com/it/u=365005294,681333190&fm=253&fmt=auto&app=138&f=JPEG?w=750&h=500",
        strategy: Option<DiskCacheStrategy>.Some(DiskCacheStrategyDATA()),
    )

    let scroller = Scroller()

    @State
    var flag1: Bool = false
    @State
    var flag2: Bool = false
    @State
    var text1: String = ""
    @State
    var text2: String = ""

    func build() {
        Column(30) {
            Scroll(this.scroller) {
                Column() {
                    Button("加载").onClick {
                        text1 = "begin1"
                        flag1 = true
                    }

                    Button("TestWebp2").onClick {Router.push(url: "TestWebp2")}

                    Text(text1)

                    if (flag1) {
                        DropletImageComponent(
                            globalContext: globalAbilityContext,
                            option: option,
                            beginFn: {=>
                                text = "begin"
                                AppLog.error("droplet hhs begin")},
                            endFn: {=>
                                textTmp = "end"
                                AppLog.error("droplet hhs end")}
                        )
                    }
                }.width(100.percent)
            }
        }
    }
}
