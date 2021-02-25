

# import xml.etree.ElementTree as ET
# tree = ET.parse('sd1000.panel')
# root = tree.getroot()

# for type_tag in root.findall('luaManager'):
#     value = type_tag.get('foobar')
#     print(value)


from pathlib import Path, PureWindowsPath

from xml.dom import minidom


def createMethodScriptFile(path, lua_method):
    lua_method_name = lua_method.attributes['luaMethodName'].value
    full_path = PureWindowsPath(path).joinpath(lua_method_name+".lua")

    lua_method_code = lua_method.attributes['luaMethodCode'].value
    
    file = open(full_path, "w")
    for s in lua_method_code:
        file.write(s)
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
            lua_methods = xmldoc.getElementsByTagName('luaMethod')
            print(f"creating {len(lua_methods)} lua script files")
            for m in lua_methods:
                createMethodScriptFile(p, m)

        except FileExistsError as exc:
            print(exc)
    pass


def main():
    panel_filename = "sd1000.panel"
    xmldoc = minidom.parse(panel_filename)
    # _lua_method_groups = xmldoc.getElementsByTagName('luaMethodGroup')
    # createFoldersOnly(panel_filename.split(".")[0],_lua_method_groups)
    createFoldersAndScriptFiles(panel_filename.split(".")[0], xmldoc)

    




    # itemlist = xmldoc.getElementsByTagName('luaMethod')
    # print(len(itemlist))

    # for s in itemlist:
    #     print(s.attributes['luaMethodName'].value)

    # print(itemlist[0].attributes['luaMethodCode'].value)
    # for s in itemlist:
    #     print(s.attributes['luaMethodCode'].value)


    # for 

    # file = open("testfile.txt", "w")

    # file.write()

    # file.close()


if __name__ == "__main__":
    # execute only if run as a script
    main()