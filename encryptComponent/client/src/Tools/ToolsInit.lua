appdf.req(appdf.CLIENT_SRC.."Tools.GlobalUserItem")
appdf.req(appdf.CLIENT_SRC.."Tools.GlobalRubCardLayer")
appdf.req(appdf.CLIENT_SRC .. "Tools.NativeBridge")
appdf.req(appdf.CLIENT_SRC .. "Tools.ccfix")

g_ExternalFun = appdf.req(appdf.CLIENT_SRC.."Tools.ExternalFun")
ef = g_ExternalFun
g_MultiPlatform = appdf.req(appdf.CLIENT_SRC .. "Tools.MultiPlatform")
UIMgr = appdf.req(appdf.CLIENT_SRC .. "Tools.UIMgr")
g_language = appdf.req(appdf.CLIENT_SRC .. "Tools.languageConfig")
g_platformConfig = appdf.req(appdf.CLIENT_SRC .. "Tools.PlatformConfig")
g_format = appdf.req(appdf.CLIENT_SRC.."Tools.format.formatBase").new(ylAll.ProjectSelect)

Msg = appdf.req(appdf.CLIENT_SRC .. "Tools.Msg")