-----------------------------------------------------------------------------------------
-- 本範例用來示範如何從Server抓取JSON字串，並轉換成Table。並示範如何從Server抓取圖片資料並顯示在畫面上
--
-- main.lua
-- Author:Zack Lin
-- Time: 2016/9/18
-----------------------------------------------------------------------------------------

local json = require("json")

local remoteImageResponse

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end 

--初始化，用元件呈現網路得到的資料
local function init( text , src )
    local lb = display.newText(  text, 160 , 100 , native.systemFont ,30 )
    lb:setFillColor( 1 , 1 , 1 )

    display.loadRemoteImage( src, "GET", remoteImageResponse, "coronalogogrey.png", system.TemporaryDirectory, 160 , 300 )
    --print("image src" , src)
end

--網路請求Handler
local function handleResponse(e)
	if (not e.isError) then
		local table = json.decode( e.response )
		--print_r(table)
        init(table['result']['results'][1]['A_Family'] , table['result']['results'][1]['A_Pic01_URL'])
	else
		print("request Error")
	end
end

local url = "http://data.taipei/opendata/datalist/apiAccess?scope=resourceAquire&rid=a3e2b221-75e0-45c1-8f97-75acbd43d613"

network.request( url, "GET", handleResponse )


--網路圖片請求Handler
remoteImageResponse = function ( event )
    if (not event.isError ) then
        event.target.alpha = 0
        event.target.width , event.target.height = 200 , 200
        transition.to( event.target, { alpha = 1.0 ,time = 1000} )

        print ( "event.response.fullPath: ", event.response.fullPath )
        print ( "event.response.filename: ", event.response.filename )
        print ( "event.response.baseDirectory: ", event.response.baseDirectory )
    else
        print ( "Network error - download failed" )
    end
end

