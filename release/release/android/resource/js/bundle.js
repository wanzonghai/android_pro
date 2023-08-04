(() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __decorateClass = (decorators, target, key, kind) => {
    var result = kind > 1 ? void 0 : kind ? __getOwnPropDesc(target, key) : target;
    for (var i = decorators.length - 1, decorator; i >= 0; i--)
      if (decorator = decorators[i])
        result = (kind ? decorator(target, key, result) : decorator(result)) || result;
    if (kind && result)
      __defProp(target, key, result);
    return result;
  };

  // src/Button.ts
  var { regClass, property } = Laya;
  var Button = class extends Laya.Script {
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
  __decorateClass([
    property(Laya.Button)
  ], Button.prototype, "button", 2);
  Button = __decorateClass([
    regClass("L-75NtedQnCO89kFtTS81w")
  ], Button);

  // src/GameScene.generated.ts
  var GameSceneBase = class extends Laya.Scene {
  };

  // src/GameScene.ts
  var EventType = /* @__PURE__ */ ((EventType2) => {
    EventType2["SelectStar"] = "SelectStar";
    return EventType2;
  })(EventType || {});
  var { regClass: regClass2, property: property2 } = Laya;
  var GameScene = class extends GameSceneBase {
    constructor() {
      super();
      this.rate = 1;
      this.lastClickTime = 0;
      this.teaArr = [];
      this.resultArr = [];
      this.result1 = [];
      this.result2 = [];
      this.result3 = [];
      this.betSum = 500;
      GameScene.instance = this;
    }
    onEnable() {
      this.SpinBtn.on(Laya.Event.CLICK, this, this.onClick);
      this.backBtn.on(Laya.Event.CLICK, this, this.onClick);
      this.addBtn2.on(Laya.Event.CLICK, this, this.onClick);
      this.reduceBtn2.on(Laya.Event.CLICK, this, this.onClick);
      this.initData();
      this.initGame();
    }
    initData() {
      const data = Laya.LocalStorage.getItem(GameScene.UserData);
      if (data) {
        let t = JSON.parse(data);
        this._star = t.star;
      } else {
        this._star = 2e4;
      }
      this.rate = 1;
      this.winLab.text = "0";
      this.betSum = 500;
      this.rateLab2.text = this.betSum + "";
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene.UserData, JSON.stringify(this.data));
      this.starLab.text = this._star + "";
    }
    initGame() {
      this.state = 0 /* Idle */;
    }
    addStar(sum) {
      this._star += sum + this.rate * this.betSum;
      this.starLab.text = this._star + "";
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene.UserData, JSON.stringify(this.data));
    }
    reduceStar(sum) {
      this._star -= sum * this.rate;
      this.starLab.text = this._star + "";
      this.data = { star: this._star };
      Laya.LocalStorage.setItem(GameScene.UserData, JSON.stringify(this.data));
    }
    onClick(e) {
      let currentTime = Laya.Browser.now();
      if (currentTime - this.lastClickTime <= 200) {
        return;
      }
      this.lastClickTime = currentTime;
      const btnName = e.currentTarget.name;
      switch (btnName) {
        case "SpinBtn":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          if (this._star < this.rate * this.betSum) {
            return;
          }
          this.reduceStar(this.betSum);
          this.winLab.text = "0";
          this.state = 1 /* Rolling */;
          this.startSpin();
          break;
        case "backBtn":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          Laya.Scene.open("HelpScene.ls", true);
          break;
        case "addBtn":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          if (this.rate >= 10) {
            return;
          }
          this.rate++;
          break;
        case "reduceBtn":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          if (this.rate <= 1) {
            return;
          }
          this.rate--;
          break;
        case "addBtn2":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          if (this.betSum >= 2500) {
            return;
          }
          this.betSum += 100;
          this.rateLab2.text = this.betSum + "";
          break;
        case "reduceBtn2":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          if (this.betSum <= 500) {
            return;
          }
          this.betSum -= 100;
          this.rateLab2.text = this.betSum + "";
          break;
        case "MaxBtn":
          if (this.state == 1 /* Rolling */) {
            return;
          }
          this.rate = 10;
          break;
        default:
          break;
      }
    }
    startSpin() {
      this.clear();
      this.resultArr = [];
      this.result1 = [];
      this.result2 = [];
      this.result3 = [];
      let count = 0;
      Laya.timer.loop(100, this, () => {
        for (let i = 0; i < 5; i++) {
          let result1 = this.rotationResult();
          let item = this.FBox1.getChildAt(i);
          item.skin = "resources/common/bb_" + result1 + ".png";
        }
        for (let i = 0; i < 5; i++) {
          let result2 = this.rotationResult();
          let item = this.FBox2.getChildAt(i);
          item.skin = "resources/common/bb_" + result2 + ".png";
        }
        for (let i = 0; i < 5; i++) {
          let result3 = this.rotationResult();
          let item = this.FBox3.getChildAt(i);
          item.skin = "resources/common/bb_" + result3 + ".png";
        }
        count++;
        if (count >= 30) {
          for (let i = 0; i < 5; i++) {
            let result = this.rotationResult();
            let item = this.FBox1.getChildAt(i);
            item.skin = "resources/common/bb_" + result + ".png";
            this.result1.push(result);
          }
          for (let i = 0; i < 5; i++) {
            let result = this.rotationResult();
            let item = this.FBox2.getChildAt(i);
            item.skin = "resources/common/bb_" + result + ".png";
            this.result2.push(result);
          }
          for (let i = 0; i < 5; i++) {
            let result = this.rotationResult();
            let item = this.FBox3.getChildAt(i);
            item.skin = "resources/common/bb_" + result + ".png";
            this.result3.push(result);
          }
          this.clear();
          let win = this.calScore(this.result2);
          this.addStar(win);
          this.winLab.text = win + "";
          this.state = 2 /* Stop */;
        }
      });
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
    flyGold() {
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
    rotationResult() {
      let icons = [1, 2, 3, 4, 5, 6, 7, 6];
      let probability = [0.3, 0.1, 0.2, 0.1, 0.1, 0.1, 0.1, 0.1];
      let random = Math.random();
      let sum = 0;
      let result;
      for (let i = 0; i < probability.length; i++) {
        sum += probability[i];
        if (random < sum) {
          result = icons[i];
          break;
        }
      }
      return result;
    }
    clear() {
      Laya.timer.clearAll(this);
    }
  };
  // 上一次鼠标点击的时间
  GameScene.UserData = "rfgsrg_123";
  GameScene = __decorateClass([
    regClass2("GtHbsRaoTAmZRnSDCI6EIw")
  ], GameScene);

  // src/HelpScene.generated.ts
  var HelpSceneBase = class extends Laya.Scene {
  };

  // src/HelpScene.ts
  var { regClass: regClass3, property: property3 } = Laya;
  var Script = class extends HelpSceneBase {
    //declare owner : Laya.Sprite3D;
    constructor() {
      super();
    }
    onAwake() {
      this.backBtn.on(Laya.Event.CLICK, this, () => {
        Laya.Scene.open("Scene.ls", true);
      });
      this.mouseThrough = false;
    }
    /**
     * 组件被启用后执行，例如节点被添加到舞台后
     */
    //onEnable(): void {}
    /**
     * 组件被禁用时执行，例如从节点从舞台移除后
     */
    //onDisable(): void {}
    /**
     * 第一次执行update之前执行，只会执行一次
     */
    //onStart(): void {}
    /**
     * 手动调用节点销毁时执行
     */
    //onDestroy(): void {
    /**
     * 每帧更新时执行，尽量不要在这里写大循环逻辑或者使用getComponent方法
     */
    //onUpdate(): void {}
    /**
     * 每帧更新时执行，在update之后执行，尽量不要在这里写大循环逻辑或者使用getComponent方法
     */
    //onLateUpdate(): void {}
    /**
     * 鼠标点击后执行。与交互相关的还有onMouseDown等十多个函数，具体请参阅文档。
     */
    //onMouseClick(): void {}
  };
  Script = __decorateClass([
    regClass3("6kDzhUwdR1erelxkUtEu9A")
  ], Script);
})();
