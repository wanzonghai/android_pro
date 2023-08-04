{
  "_$ver": 1,
  "_$id": "vznk3x9r",
  "_$runtime": "res://c83a781e-f1da-4b1c-a96d-376d21364967",
  "_$type": "Scene",
  "left": 0,
  "right": 0,
  "top": 0,
  "bottom": 0,
  "name": "Scene2D",
  "mouseThrough": true,
  "_$child": [
    {
      "_$id": "xhjoyexe",
      "_$type": "Panel",
      "name": "Panel",
      "width": 1920,
      "height": 1080,
      "anchorX": 0,
      "anchorY": 0,
      "left": 0,
      "right": 0,
      "top": 0,
      "bottom": 0,
      "bgColor": "rgba(0, 0, 0, 0.7843137254901961)"
    },
    {
      "_$id": "t4xoxfxp",
      "_$var": true,
      "_$type": "Image",
      "name": "winImg",
      "x": 702,
      "y": 117,
      "width": 524,
      "height": 261,
      "anchorX": 0,
      "anchorY": 0,
      "centerX": 4,
      "skin": "resources/common/kdjfiehf.png",
      "useSourceSize": true
    },
    {
      "_$id": "1u6taweg",
      "_$var": true,
      "_$type": "Image",
      "name": "loseImg",
      "x": 656,
      "y": 110,
      "width": 609,
      "height": 271,
      "anchorX": 0,
      "anchorY": 0,
      "centerX": 0,
      "skin": "resources/common/mcvnfhe.png",
      "useSourceSize": true
    },
    {
      "_$id": "2dac2mmy",
      "_$var": true,
      "_$type": "Button",
      "name": "closeBtn",
      "x": 960,
      "y": 864.5,
      "width": 426,
      "height": 174,
      "anchorX": 0.5,
      "anchorY": 0.5,
      "mouseEnabled": true,
      "centerX": 0,
      "stateNum": 1,
      "skin": "resources/common/hefy.png",
      "sizeGrid": "11,11,13,10,0",
      "label": "",
      "labelSize": 50,
      "labelBold": true,
      "labelColors": "#fc5353,#ffffff,#ffffff,#c0c0c0",
      "labelPadding": "0,0,5,0",
      "_$comp": [
        {
          "_$type": "2feef936-d79d-4270-8ef3-d905b534bcd7",
          "scriptPath": "../src/Button.ts",
          "button": {
            "_$ref": "2dac2mmy"
          }
        }
      ]
    },
    {
      "_$id": "cy4eqobc",
      "_$var": true,
      "_$type": "Label",
      "name": "resultLab",
      "x": 881,
      "y": 514,
      "width": 158,
      "height": 64,
      "anchorX": 0,
      "anchorY": 0,
      "centerX": 0,
      "text": "Label",
      "fontSize": 50,
      "color": "rgba(240, 255, 0, 1)",
      "align": "center",
      "valign": "middle",
      "leading": 0,
      "padding": "0,0,0,0"
    }
  ]
}