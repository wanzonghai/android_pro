
function __decorate(decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function")
        r = Reflect.decorate(decorators, target, key, desc);
    else
        for (let i = decorators.length - 1; i >= 0; i--)
            if (d = decorators[i])
                r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}

function __metadata(k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") {
        return Reflect.metadata(k, v);
    }
}

var _regClass = window._regClass;
var _dummyRegClass = Laya.regClass();
function __$decorate(assetId, codePath) {
    return function(...args) {
        let i = args[0].indexOf(_dummyRegClass);
        if (i != -1) {
            if (_regClass)
                args[0][i] = _regClass(assetId, codePath);
            else
                args[0][i] = function(constructor) { Laya.ClassUtils.regClass(assetId, constructor); };
        }
        return __decorate(...args);
    }
}

(() => {
  // ../../../../../../jh_mjb/Slot Flavor/src/Button.ts
  var __decorate = __$decorate("2feef936-d79d-4270-8ef3-d905b534bcd7", "");
  var _a;
  var { regClass, property } = Laya;
  var Button = class Button2 extends Laya.Script {
    constructor() {
      super();
    }
    onEnable() {
      this.button.on(Laya.Event.MOUSE_DOWN, this, this.onMouseDownClick);
      this.button.on(Laya.Event.MOUSE_UP, this, this.onMouseUpClick);
      this.button.on(Laya.Event.MOUSE_OUT, this, this.onMouseOutClick);
    }
    onMouseDownClick() {
      Laya.Tween.to(this.button, { scaleX: 0.8, scaleY: 0.8 }, 100);
    }
    onMouseUpClick() {
      Laya.Tween.to(this.button, { scaleX: 1, scaleY: 1 }, 100);
    }
    onMouseOutClick() {
      Laya.Tween.to(this.button, { scaleX: 1, scaleY: 1 }, 100);
    }
    onDisable() {
      Laya.Tween.clearTween(this.button);
    }
  };
  __decorate([
    property(),
    __metadata("design:type", typeof (_a = typeof Laya !== "undefined" && Laya.Button) === "function" ? _a : Object)
  ], Button.prototype, "button", void 0);
  Button = __decorate([
    regClass(),
    __metadata("design:paramtypes", [])
  ], Button);

  // ../../../../../../jh_mjb/Slot Flavor/src/GameScene.generated.ts
  var GameSceneBase = class extends Laya.Scene {
  };

  // ../../../../../../jh_mjb/Slot Flavor/src/GameScene.ts
  var __decorate2 = __$decorate("1ad1dbb1-16a8-4c09-9946-7483088e8423", "");
  var GameScene_1;
  var EventType;
  (function(EventType2) {
    EventType2["SelectStar"] = "SelectStar";
  })(EventType || (EventType = {}));
  var { regClass: regClass2, property: property2 } = Laya;
  var SlotMachineState;
  (function(SlotMachineState2) {
    SlotMachineState2[SlotMachineState2["Idle"] = 0] = "Idle";
    SlotMachineState2[SlotMachineState2["Rolling"] = 1] = "Rolling";
    SlotMachineState2[SlotMachineState2["Stop"] = 2] = "Stop";
  })(SlotMachineState || (SlotMachineState = {}));
  var GameScene = GameScene_1 = class GameScene2 extends GameSceneBase {
    constructor() {
      super();
      this.rate = 1;
      this.lastClickTime = 0;
      this.teaArr = [];
      this.resultArr = [];
      this.result1 = [];
      this.result2 = [];
      this.result3 = [];
      this.betSum = 1500;
      this.betArr = [30, 40, 50, 60, 70, 80, 90];
      this.curIndex = 0;
      this.roundIndex = 0;
      this.allIndex = 0;
      GameScene_1.instance = this;
    }
    onEnable() {
      this.goBtn.on(Laya.Event.CLICK, this, this.onClick);
      this.goBack.on(Laya.Event.CLICK, this, this.onClick);
      this.bet1Btn.on(Laya.Event.CLICK, this, this.onClick);
      this.bet2Btn.on(Laya.Event.CLICK, this, this.onClick);
      this.bet3Btn.on(Laya.Event.CLICK, this, this.onClick);
      this.bet4Btn.on(Laya.Event.CLICK, this, this.onClick);
      this.initData();
      this.initGame();
      Laya.timer.loop(50, this, this.update);
    }
    initData() {
      const data = Laya.LocalStorage.getItem(GameScene_1.UserData);
      if (data) {
        let t = JSON.parse(data);
        this._star = t.star;
      } else {
        this._star = 8e3;
      }
      this.rate = 1;
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene_1.UserData, JSON.stringify(this.data));
      this.starLab.text = this._star + "";
    }
    initGame() {
      this.state = SlotMachineState.Idle;
      this.showASelect(GameScene_1.startIndex);
    }
    showASelect(index) {
      for (let i = 0; i < this.blockBox.numChildren; i++) {
        this.hideSelect(i);
      }
      let item = this.blockBox.getChildAt(index).getChildAt(0);
      item.visible = true;
    }
    hideSelect(index) {
      let item = this.blockBox.getChildAt(index).getChildAt(0);
      item.visible = false;
    }
    startGame() {
      this.roundIndex = Math.floor(Math.random() * 10) + 1;
      this.allIndex = 50 + this.roundIndex;
      this.state = SlotMachineState.Rolling;
      this.curIndex = GameScene_1.startIndex;
    }
    update() {
      if (this.state != SlotMachineState.Rolling) {
        return;
      }
      if (this.allIndex <= 0) {
        this.state = SlotMachineState.Idle;
        let gold = this.betArr[this.getIndexMap(this.roundIndex) - 1];
        if (Math.random() > 0.5) {
          this.addStar(gold);
          Laya.timer.once(350, this, () => {
            Laya.Scene.open("ResultScene.ls", false, { isWin: true, sum: gold });
          });
        } else {
          this.reduceStar(gold);
          Laya.timer.once(350, this, () => {
            Laya.Scene.open("ResultScene.ls", false, { isWin: false, sum: gold });
          });
        }
        return;
      }
      this.allIndex--;
      this.showASelect(this.curIndex);
      this.curIndex++;
      if (this.curIndex >= 10) {
        this.curIndex = 0;
      }
    }
    getIndexMap(index) {
      if (index == 1) {
        return 4;
      } else if (index == 2) {
        return 2;
      } else if (index == 3) {
        return 3;
      } else if (index == 4) {
        return 1;
      } else if (index == 5) {
        return 3;
      } else if (index == 6) {
        return 5;
      } else if (index == 7) {
        return 6;
      } else if (index == 8) {
        return 1;
      } else if (index == 9) {
        return 5;
      } else {
        return 7;
      }
    }
    addStar(sum) {
      this._star += sum;
      this.starLab.text = this._star + "";
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene_1.UserData, JSON.stringify(this.data));
    }
    reduceStar(sum) {
      this._star -= sum;
      this.starLab.text = this._star + "";
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene_1.UserData, JSON.stringify(this.data));
    }
    onClick(e) {
      let currentTime = Laya.Browser.now();
      if (currentTime - this.lastClickTime <= 200) {
        return;
      }
      this.lastClickTime = currentTime;
      const btnName = e.currentTarget.name;
      switch (btnName) {
        case "goBtn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.reduceStar(50);
          this.startGame();
          break;
        case "allBtn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          for (let i = 0; i < this.betArr.length; i++) {
            this.betArr[i]++;
          }
          break;
        case "bet1Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[3]++;
          break;
        case "bet2Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[4]++;
          break;
        case "bet3Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[2]++;
          break;
        case "bet4Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[1]++;
          break;
        case "bet5Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[0]++;
          break;
        case "bet6Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[5]++;
          break;
        case "bet7Btn":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          this.betArr[6]++;
          break;
        case "goBack":
          if (this.state == SlotMachineState.Rolling) {
            return;
          }
          Laya.Scene.open("HelpScene.ls", true);
          break;
        default:
          break;
      }
    }
    calScore(arr) {
      let sum = 0;
      for (let i = 0; i < arr.length; i++) {
        if (arr[i] == 1) {
          sum += 400;
        } else if (arr[i] == 2) {
          sum += 200;
        } else if (arr[i] == 3) {
          sum += 400;
        } else if (arr[i] == 4) {
          sum += 400;
        } else if (arr[i] == 5) {
          sum += 400;
        } else if (arr[i] == 6) {
          sum += 200;
        } else {
          sum += 200;
        }
      }
      return sum;
    }
    hasDuplicate(arr) {
      for (let i = 0; i < arr.length; i++) {
        let current = arr[i];
        let count = 0;
        for (let j = i + 1; j < arr.length; j++) {
          if (arr[j] === current) {
            count++;
          }
        }
        if (count === 2 || count === 3 || count === 4 || count === 5) {
          return count + 1;
        }
      }
      return 0;
    }
    clear() {
      Laya.timer.clearAll(this);
    }
  };
  GameScene.UserData = "kvjifje_1";
  GameScene.startIndex = 0;
  GameScene = GameScene_1 = __decorate2([
    regClass2(),
    __metadata("design:paramtypes", [])
  ], GameScene);

  // ../../../../../../jh_mjb/Slot Flavor/src/HelpScene.generated.ts
  var HelpSceneBase = class extends Laya.Scene {
  };

  // ../../../../../../jh_mjb/Slot Flavor/src/HelpScene.ts
  var __decorate3 = __$decorate("ea40f385-4c1d-4757-ab7a-5c6452d12ef4", "");
  var { regClass: regClass3, property: property3 } = Laya;
  var Script = class Script2 extends HelpSceneBase {
    //declare owner : Laya.Sprite3D;
    constructor() {
      super();
    }
    onAwake() {
      this.startGame.on(Laya.Event.CLICK, this, () => {
        Laya.Scene.open("Scene.ls", true);
      });
      this.mouseThrough = false;
    }
  };
  Script = __decorate3([
    regClass3(),
    __metadata("design:paramtypes", [])
  ], Script);

  // ../../../../../../jh_mjb/Slot Flavor/src/ResultScene.generated.ts
  var ResultSceneBase = class extends Laya.Scene {
  };

  // ../../../../../../jh_mjb/Slot Flavor/src/ResultScene.ts
  var __decorate4 = __$decorate("c83a781e-f1da-4b1c-a96d-376d21364967", "");
  var { regClass: regClass4, property: property4 } = Laya;
  var ResultScene = class ResultScene2 extends ResultSceneBase {
    //declare owner : Laya.Sprite3D;
    constructor() {
      super();
    }
    /**
     * 组件被激活后执行，此时所有节点和组件均已创建完毕，此方法只执行一次
     */
    onAwake() {
      this.closeBtn.on(Laya.Event.CLICK, this, () => {
        GameScene.instance.initGame();
        this.close();
      });
      this.mouseThrough = false;
    }
    onOpened(param = null) {
      if (param) {
        if (param.isWin) {
          this.winImg.visible = true;
          this.loseImg.visible = false;
          this.resultLab.text = "WIN: +" + param.sum;
        } else {
          this.winImg.visible = false;
          this.loseImg.visible = true;
          this.resultLab.text = "LOSE: -" + param.sum;
        }
      }
    }
    onEnable() {
    }
  };
  ResultScene = __decorate4([
    regClass4(),
    __metadata("design:paramtypes", [])
  ], ResultScene);
})();
