import sys
import ufoLib2
import ufo2ft
import subprocess
from ufo2ft.fontInfoData import getAttrWithFallback
from fontTools.designspaceLib import DesignSpaceDocument
from fontTools.ttLib import newTable
from fontTools.misc.roundTools import otRound

def open_ufo(path):
    return ufoLib2.Font.open(path)

class CJKOutlineTTFCompiler(ufo2ft.outlineCompiler.OutlineTTFCompiler):

    @staticmethod
    def makeMissingRequiredGlyphs(font, glyphSet, sfntVersion, notdefGlyph=None):
        # Make sure we don't add .notdef
        return

    def setupTable_post(self):
        # post table must be format 3
        if "post" not in self.tables:
            return

        self.otf["post"] = post = newTable("post")
        font = self.ufo
        post.formatType = 3.0
        # italic angle
        italicAngle = getAttrWithFallback(font.info, "italicAngle")
        post.italicAngle = italicAngle
        # underline
        underlinePosition = getAttrWithFallback(
            font.info, "postscriptUnderlinePosition"
        )
        post.underlinePosition = otRound(underlinePosition)
        underlineThickness = getAttrWithFallback(
            font.info, "postscriptUnderlineThickness"
        )
        post.underlineThickness = otRound(underlineThickness)
        post.isFixedPitch = getAttrWithFallback(font.info, "postscriptIsFixedPitch")
        # misc
        post.minMemType42 = 0
        post.maxMemType42 = 0
        post.minMemType1 = 0
        post.maxMemType1 = 0

def build(designspace, filename, tableDir):
    designspace = DesignSpaceDocument.fromfile(designspace)
    designspace.loadSourceFonts(opener=open_ufo)

    font = ufo2ft.compileVariableTTF(
            designspace,
            outlineCompilerClass=CJKOutlineTTFCompiler,
            inplace=True,
        )

    dest = "../fonts/variable/" + filename
    font.save(dest)

    subprocess.run(["sfntedit", "-a", "cmap={0}/.tb_cmap,GDEF={0}/.tb_GDEF,GPOS={0}/.tb_GPOS,GSUB={0}/.tb_GSUB,DSIG={0}/.tb_DSIG,name={0}/.tb_name,OS/2={0}/.tb_OS2,hhea={0}/.tb_hhea,post={0}/.tb_post,STAT={0}/.tb_STAT,fvar={0}/.tb_fvar".format(tableDir), dest])

build("ChironHeiHK.designspace", "ChironHeiHK-[wght].ttf", "tables")
build("ChironHeiHK-Italic.designspace", "ChironHeiHK-Italic-[wght].ttf", "tables-italic")
