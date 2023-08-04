{
  "_$ver": 1,
  "_$id": "abmat63y",
  "_$runtime": "res://ea40f385-4c1d-4757-ab7a-5c6452d12ef4",
  "_$type": "Scene",
  "left": 0,
  "right": 0,
  "top": 0,
  "bottom": 0,
  "name": "Scene2D",
  "mouseThrough": true,
  "_$child": [
    {
      "_$id": "kwo4jy5d",
      "_$type": "Image",
      "name": "Image",
      "width": 1920,
      "height": 1080,
      "anchorX": 0,
      "anchorY": 0,
      "left": 0,
      "right": 0,
      "top": 0,
      "bottom": 0,
      "skin": "resources/common/owkfi.png",
      "useSourceSize": true
    },
    {
      "_$id": "4tubgy91",
      "_$type": "Box",
      "name": "Box",
      "x": 860,
      "y": 428,
      "width": 200,
      "height": 200,
      "anchorX": 0,
      "anchorY": 0,
      "mouseEnabled": true,
      "centerX": 0,
      "_$child": [
        {
          "_$id": "ly5900pz",
          "_$type": "Text",
          "name": "Text",
          "x": -412.99999999999983,
          "y": -285,
          "width": 995,
          "height": 279,
          "anchorX": 0,
          "anchorY": 0,
          "text": "Slot Flavor",
          "fontSize": 200,
          "color": "#FFFFFF",
          "align": "center",
          "valign": "middle",
          "leading": 0
        }
      ]
    },
    {
      "_$id": "u7jldi2h",
      "_$var": true,
      "_$type": "Button",
      "name": "startGame",
      "x": 960.0000000000002,
      "y": 690.0000000000001,
      "width": 426,
      "height": 174,
      "anchorX": 0.5,
      "anchorY": 0.5,
      "mouseEnabled": true,
      "centerX": 0,
      "centerY": 150,
      "stateNum": 1,
      "skin": "resources/common/ufehyg.png",
      "label": "",
      "labelSize": 55,
      "labelBold": true,
      "labelColors": "#ffffff,#32cc6b,#ff0000,#c0c0c0",
      "_$comp": [
        {
          "_$type": "2feef936-d79d-4270-8ef3-d905b534bcd7",
          "scriptPath": "../src/Button.ts",
          "button": {
            "_$ref": "u7jldi2h"
          }
        }
      ]
    }
  ]
}