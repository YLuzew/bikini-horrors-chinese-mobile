// Script by bctix
import flixel.text.FlxTextBorderStyle;
import flixel.text.FlxTextFormatMarkerPair;
import flixel.text.FlxTextFormat;
import flixel.text.FlxText.FlxTextAlign;

var lyricsConfig = {
    xOffset: 0,
    yOffset: 0,
    color: FlxColor.WHITE,
    borderColor: FlxColor.BLACK,
    font: "KrabbyPatty",
    chineseFont: "HanyiYongZiDingShengGao", // \n 之后的文字使用的字体
    size: 34,
    borderSize: 2,
    textSpaceMovementMult: 1,
    showHistory: true
}

var textGroup:FlxTypedGroup;

function create()
{
    textGroup = new FlxTypedGroup();
    add(textGroup);
}

function onEvent(eventEvent) {
    if(eventEvent.event.name != "Lyrics") return;
    switch(eventEvent.event.params[0]) {
        case "Add Text":
            addText(eventEvent.event.params[1]);

        case "Force remove all text":
            killText();

        case "Set Color":
            lyricsConfig.color = eventEvent.event.params[2];

        case "Set Border Color":
            lyricsConfig.borderColor = eventEvent.event.params[2];

        case "Set Font":
            lyricsConfig.font = eventEvent.event.params[1];

        case "Set Chinese Font":
            lyricsConfig.chineseFont = eventEvent.event.params[1];

        case "Set Size":
            lyricsConfig.size = eventEvent.event.params[1];

        case "Enable text history (On, Off)":
            lyricsConfig.showHistory = eventEvent.event.params[3];
            trace(eventEvent.event.params[3]);
        case "Change text offset":
            trace(eventEvent.event.params[2]);
            lyricsConfig.xOffset = Std.int(eventEvent.event.params[1].split(",")[0]);
            lyricsConfig.yOffset = Std.int(eventEvent.event.params[1].split(",")[1]);
    }
}

function addText(setText)
{
    for(i in textGroup.members)
    {
        if(lyricsConfig.showHistory)
        {
            var spaceToMove = !camHUD.downscroll ? lyricsConfig.size : -1 * lyricsConfig.size;
            spaceToMove *= lyricsConfig.textSpaceMovementMult;
            FlxTween.tween(i, {alpha: i.alpha - 0.7, y: i.y - spaceToMove}, 0.3, {ease: FlxEase.cubeOut, onComplete: function(t){
                if(i.alpha == 0)
                {
                    textGroup.remove(i, true);
                    i.destroy();
                }
            }});
        } else {
            textGroup.remove(i, true);
            i.destroy();
        }
    }

    // 同时兼容 JSON 里写的 "\n"（真换行）和 "\\n"（字面量反斜杠 n）
    var normalized = StringTools.replace(setText, "\\n", "\n");
    var lines = normalized.split("\n");

    var lineHeight = lyricsConfig.size + 4;
    var baseY = 500 + lyricsConfig.yOffset;
    // 让整体多行文本视觉上以 baseY 为中心
    var startY = baseY - ((lines.length - 1) * lineHeight) / 2;

    for (idx in 0...lines.length)
    {
        var line = lines[idx];
        if (line == null || line == "") continue;

        // 第一行用原字体，\n 之后的行用中文专用字体
        var fontName = (idx == 0) ? lyricsConfig.font : lyricsConfig.chineseFont;

        var text = new FlxText(0, startY + idx * lineHeight);
        text.setFormat(getFont(fontName), lyricsConfig.size, lyricsConfig.color, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, lyricsConfig.borderColor);
        text.borderSize = lyricsConfig.borderSize;
        text.text = line;
        text.screenCenter(FlxAxes.X);
        text.x += lyricsConfig.xOffset;
        text.cameras = [camHUD];
        textGroup.add(text);
    }
}

function getFont(fontName:String = null)
{
    if (fontName == null) fontName = lyricsConfig.font;
    trace(Paths.font(fontName));
    if(StringTools.endsWith(fontName, ".ttf") || StringTools.endsWith(fontName, ".otf"))
        return Paths.font(fontName);

    if(Assets.exists(Paths.font(fontName) + ".ttf"))
        return Paths.font(fontName) + ".ttf";

    if(Assets.exists(Paths.font(fontName) + ".otf"))
        return Paths.font(fontName) + ".otf";

    return Paths.font(fontName);
}

function killText()
{
    for(i in textGroup.members)
    {
        FlxTween.tween(i, {alpha: 0}, 0.3, {ease: FlxEase.cubeOut, onComplete: function(t){
            textGroup.remove(i, true);
            i.destroy();
        }});
    }
}