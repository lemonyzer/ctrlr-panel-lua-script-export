

# import xml.etree.ElementTree as ET
# tree = ET.parse('sd1000.panel')
# root = tree.getroot()

# for type_tag in root.findall('luaManager'):
#     value = type_tag.get('foobar')
#     print(value)


from pathlib import Path, PureWindowsPath

from xml.dom import minidom


# Example
#<panel>
# <luaManager>
#  <luaManagerMethods>
#   <luaMethodGroup name="Efx" uuid="4c6c3d448aae40b1affc1ef084551d80">
#     <luaMethod luaMethodName="setModPresetEfx" luaMethodCode="function sendSysExMessage(msgData)&#13;&#10;&#13;&#10;&#9;--xx = tonumber(fxModeValue,16)&#13;&#10;&#13;&#10;&#9;--XX = 0x00 -- don't care&#13;&#10;&#13;&#10;&#9;--msgData = { 0xF0, 0x41, 0x00, 0x42, 0x12, 0x40, combinedByte, 0x22, 0x00, XX, 0xF7 }&#9;&#9;--&lt;-- Reset: track in normal mode&#13;&#10;&#13;&#10;&#9;console (string.format(&quot;sendSysExMessage (msgData=%s)&quot;, MemoryBlock(msgData):toHexString(1)))&#13;&#10;&#13;&#10;--&#9;for k,v in pairs(msgData) do console(string.format(&quot;SysEx: %d,%02x&quot;, k,v)) end&#13;&#10;&#9;--console ( tostring(msgData) )&#13;&#10;&#13;&#10;&#9;newMidiMessage = CtrlrMidiMessage( msgData )&#13;&#10;&#9;panel:sendMidiMessageNow(newMidiMessage)&#13;&#10;&#10;end"
#                luaMethodLinkedProperty="" luaMethodSource="0" uuid="211c6dcc7ad0445ca86ffac96981e513"
#                luaMethodValid="1"/>
#   </luaMethodGroup>
#   <luaMethodGroup name="MIDI" uuid="4c6c3d448aae40b1affc1ef084551d80">
#     <luaMethod luaMethodName="sendSysExMessage" luaMethodCode="function sendSysExMessage(msgData)&#13;&#10;&#13;&#10;&#9;--xx = tonumber(fxModeValue,16)&#13;&#10;&#13;&#10;&#9;--XX = 0x00 -- don't care&#13;&#10;&#13;&#10;&#9;--msgData = { 0xF0, 0x41, 0x00, 0x42, 0x12, 0x40, combinedByte, 0x22, 0x00, XX, 0xF7 }&#9;&#9;--&lt;-- Reset: track in normal mode&#13;&#10;&#13;&#10;&#9;console (string.format(&quot;sendSysExMessage (msgData=%s)&quot;, MemoryBlock(msgData):toHexString(1)))&#13;&#10;&#13;&#10;--&#9;for k,v in pairs(msgData) do console(string.format(&quot;SysEx: %d,%02x&quot;, k,v)) end&#13;&#10;&#9;--console ( tostring(msgData) )&#13;&#10;&#13;&#10;&#9;newMidiMessage = CtrlrMidiMessage( msgData )&#13;&#10;&#9;panel:sendMidiMessageNow(newMidiMessage)&#13;&#10;&#10;end"
#                luaMethodLinkedProperty="" luaMethodSource="0" uuid="211c6dcc7ad0445ca86ffac96981e513"
#                luaMethodValid="1"/>
#   </luaMethodGroup>

# luaMethodGroups (parentNode)
# |
# |->luaMethod (childNode)
#    |.Attribut['luaMethodCode']

# itemlist = xmldoc.getElementsByTagName('luaMethod')
# for s in itemlist:
#     print(s.attributes['luaMethodName'].value)

def createMethodScriptFile(path, lua_method):
    lua_method_name = lua_method.attributes['luaMethodName'].value
    full_path = PureWindowsPath(path).joinpath(lua_method_name+".lua")

    #lua_method_code = lua_method.attributes['luaMethodCode'].value
    lua_method_code = lua_method.attributes['luaMethodCode'].value
    
    file = open(full_path, "w")
    file.write(lua_method_code)
    # for s in lua_method_code:
    #     file.write(s)
    file.close()

def createFoldersOnly(root_folder, lua_method_groups):
    # make folder 
    print(len(lua_method_groups))
    for lua_method_group in lua_method_groups:
        print(f"create folder {lua_method_group.attributes['name'].value}")
        p = Path(PureWindowsPath(root_folder).joinpath(lua_method_group.attributes['name'].value))
        try:
            p.mkdir(parents=True)

        except FileExistsError as exc:
            print(exc)


def createFoldersAndScriptFiles(root_folder, xmldoc):
    lua_method_groups = xmldoc.getElementsByTagName('luaMethodGroup')
    print(f"creating {len(lua_method_groups)} folders")
    for lua_method_group in lua_method_groups:
        print(f"create folder {lua_method_group.attributes['name'].value}")
        p = Path(PureWindowsPath(root_folder).joinpath(lua_method_group.attributes['name'].value))
        try:
            p.mkdir(parents=True)

        except FileExistsError as exc:
            print(exc)

        if p.is_dir():
            # create Script Files
            lua_methods = lua_method_group.getElementsByTagName('luaMethod')
            #lua_methods = lua_method_group.childNodes
            print(f"creating {len(lua_methods)} lua script files")
            for m in lua_methods:
                createMethodScriptFile(p, m)
    pass


def main():
    panel_filename = "sd1000.panel"
    xmldoc = minidom.parse(panel_filename)
    # _lua_method_groups = xmldoc.getElementsByTagName('luaMethodGroup')
    # createFoldersOnly(panel_filename.split(".")[0],_lua_method_groups)
    createFoldersAndScriptFiles(panel_filename.split(".")[0], xmldoc)



if __name__ == "__main__":
    # execute only if run as a script
    main()