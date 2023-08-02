--
-- Author: senji
-- Date: 2017-04-23 04:02:07
--

DeployTweenBean = class_quick("DeployTweenBean")
local prefix = "clientcore.com.luatween."
require(prefix.."plugins.AutoAlphaPlugin");
require(prefix.."plugins.BezierPlugin");
require(prefix.."plugins.ShortRotationPlugin");
require(prefix.."plugins.TintPlugin")

function DeployTweenBean:start()
	 CustomEase.create("myShakeEase1", {{s = 0,cp = 1.14799,e = 1.05},{s = 1.05,cp = 0.952,e = 0.988},{s = 0.988,cp = 1.024,e = 1}});
	 CustomEase.create("myBackEase1", {{s = 0,cp = 1.15799,e = 1.051},{s = 1.051,cp = 0.944,e = 1}});
	 CustomEase.create("myElasticEaseOut", {{s = 0,cp = 0.58399,e = 0.84},{s = 0.84,cp = 1.096,e = 1.024},{s = 1.024,cp = 0.952,e = 1}});
	 TweenPlugin.activate({ AutoAlphaPlugin, BezierPlugin, ShortRotationPlugin, TintPlugin });
end

DeployTweenBean:start()
