/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

package ohos_app_cangjie_entry

import ohos.state_macro_manage.*

@Entry
@Component
class Index_LLT {
    let arr_L0 = Array<String>(
        [
            "CaseAddListener",
            "TestCallBack",
            "TestGetOriSize",
            "CaseAddListener2",
            "CaseTrans",
            "CaseRes",
            "CaseBmp",
            "Casejpg",
            "CasePng",
            "Casewebp",
            "CaseBmp1",
            "CaseBmp2",
            "CaseBmpPlaceError",
            "CaseCenterCrop",
            "CaseCenterInside",
            "CaseCircleCrop",
            "CaseCompApply",
            "CaseCompBmp",
            "CaseCompCacheStrategyData",
            "CaseCompCacheStrategyNone",
            "CaseCompGif",
            "CaseCompJpg",
            "CaseCopmCacheStrategyResource",
            "CaseDroplet",
            "CaseErr",
            "CaseError2",
            "CaseErrorPic",
            "CaseExample",
            "CaseExampleRoundCorner",
            "CaseFitCenter",
            "CaseGetOverrideHeight",
            "CaseGetOverrideWidth",
            "CaseGetThumbsizeMultiplier",
            "CaseGif1",
            "CaseGifInto",
            "CaseGranularRound",
            "CaseInto",
            "CaseInto2",
            "CaseInto3",
            "CaseInto4",
            "CaseInto5",
            "CaseIsDiskCacheStrategySet",
            "CaseJpg1",
            "CaseLabel",
            "CaseLifecycler",
            "CaseListener",
            "CaseListener2",
            "CaseLoad",
            "CaseLoad2",
            "CaseOnlyrRtrieveFromCache",
            "CaseOverride",
            "CasePicList",
            "CasePicListTrans",
            "CasePng",
            "CaseRetrieveFromCache",
            "CaseRotate",
            "CaseSetDiskCacheStrategyAll",
            "CasesetDiskCacheStrategyData",
            "CaseSetDiskCacheStrategyNone",
            "CaseSetDiskCacheStrategyResource",
            "CaseSetOverride",
            "CaseSetOverride2",
            "CaseSetOverride3",
            "CaseSize",
            "CaseSkipMemoryCache",
            "CaseSkipMemoryCacheFalse",
            "CaseSkipMemoryCacheTrue",
            "CaseSubmit",
            "CaseSubmit2",
            "CaseThumbnail",
            "CaseTwoGif",
            "CaseUseDefaultRequestOption",
            "CaseWebp",
            "TestDropletError1",
            "TestCallBack"
        ]
    )

    func build() {
        Scroll(Scroller()) {
            Column {
                ForEach(
                    arr_L0,
                    itemGeneratorFunc: {
                        item: String, _: Int64 => Button(item).height(40).margin(top: 5, bottom: 5).fontSize(16).shape(
                            ShapeType.Capsule).onClick {Router.push(url: item)}
                    }
                )
            }.width(100.percent)
        }
    }
}
