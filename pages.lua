content = {}
pages = {}

function addPage()
	local pageNumber = #content+1
	content[#content+1] =  
	{
		background = nil,
		setBackground = function(path)
			content[pageNumber].background = paintutils.loadImage(path)
		end,
		getBackground = function()
			return content[pageNumber].background
		end,
		pageContent = 
		{
			objects = {},
			getObjects = function(oType)--string type
				temp = {}
				if(oType=="*")then
					return content[pageNumber].pageContent.objects
				else
					for i=1,#content[pageNumber].pageContent.objects,1 do
						if(content[pageNumber].pageContent.objects[i].objectType==oType)then
							temp[#temp+1] = content[pageNumber].pageContent.objects[i]
						end
					end
					return temp
				end
			end,
			addObject = function(oType,obj)--string type, table of object elements
				content[pageNumber].pageContent.objects[#content[pageNumber].pageContent.objects+1] = {objectType = oType, object = obj}
				return content[pageNumber].pageContent.objects[#content[pageNumber].pageContent.objects+1]
			end
			
		}
	} 
	pages[#pages+1] = content[number]
	return content[pageNumber]
end

drawing = 
{
	displayImage = function(image,x,y)
		paintutils.drawImage(image,x,y)
	end,
	fillArea = function(color,xpos,ypos,wid,high)
		term.setCursorPos(1,1)

		term.setBackgroundColor(color)
		for y=ypos,ypos+high-1,1 do
			for x=xpos,xpos+wid-1,1 do
				term.setCursorPos(x,y)
				write(" ")
			end
		end
	end,
	writeText = function(text,x,y,color,bgcolor)
		term.setBackgroundColor(color)
		term.setCursorPos(x,y)
		write(text)
	end,
	writeTextCentered = function(text,x,y,wid,high,color,bgcolor)
		term.setCursorPos(x+(wid-#text)/2,y+high/2)
		term.setTextColor(color)
		term.setBackgroundColor(bgcolor)
		term.write(text)
	end,
	clear = function()
		term.setBackgroundColor(colors.black)
		term.clear()
		term.setCursorPos(1,1)
	end
}

Objects = 
{
	Buttons = {},
	Labels = {},
	Images = {},
	DropDowns = {},
	ScrollBars = {},
	ProgressBars = {},
	TextBoxes = {},
	NotificationWindows = {}
}


function newButton(text,xpos,ypos,wid,high,c,tc,f)--Button text, x position, y position, width, height, color, text color, Button Function
	local itemNumber = #Objects.Buttons+1
	Objects.Buttons[itemNumber] = 
	{
		attributes = {name = text,x = xpos,y = ypos,width = wid,height = high,color = c,textcolor = tc,visible = true,buttonFunction = f},
		draw = function()
			b = Objects.Buttons[itemNumber].attributes
			drawing.fillArea(b.color,b.x,b.y,b.width,b.height)      
			drawing.writeTextCentered(b.name,b.x,b.y,b.width,b.height,b.textcolor,b.color)
		end,
		clicked = function(xpos,ypos,executeF)--executeF tells the function whether or not to execute the button's function 
			b = Objects.Buttons[itemNumber].attributes
			if(xpos>=b.x and xpos<=b.x+b.width-1) then
				if(ypos>=b.y and ypos<=b.y+b.height-1) then
					if(executeF)then
						b.buttonFunction()
					end
					return true
				end
			end
			return false
		end,
		setVisibility = function(boolean)
			Objects.Buttons[itemNumber].attributes.visible = boolean
		end
	}
	return Objects.Buttons[itemNumber]
end


function newLabel(t,xpos,ypos,w,h,centH,centV,c,tc)--the text for a label is a table i.e. {"hello world" , "This is a test"} or {"hello world"}
											--Label text, x position, y position, width, height, centered horizontally?, centered vertically?, color, text color
	local itemNumber = #Objects.Labels+1
	Objects.Labels[itemNumber] = 
	{
		attributes = {text = t,x = xpos,y = ypos,width = w,height = h,centeredH = centH,centeredV = centV,color = c,textcolor = tc,visible = true},
		setText = function(t)
			Objects.Labels[itemNumber].attributes.text = t
		end,
		draw = function()
			l = Objects.Labels[itemNumber].attributes
			drawing.fillArea(l.color,l.x,l.y,l.width,l.height)
			if(l.centeredH)then
				for i=1,#l.text,1 do
					drawing.writeTextCentered(l.text[i],l.x,l.y+(i-1),l.width,1,l.textcolor,l.color)
				end
			else
				for i=1,#l.text,1 do
					drawing.writeText(l.text[i],l.x,l.y+(i-1),l.textcolor,l.color)
				end
			end
		end,
		setVisibility = function(boolean)
			Objects.Lables[itemNumber].attributes.visible = boolean
		end
	}
	return Objects.Labels[itemNumber]
end

function newImage(path,xpos,ypos,click,f)--Image path, x position, y position, click-able?, function
	itemNumber = #Object.Images+1
	temp = {}
	if(f==nil)then
		temp = {image = paintutils.loadImage(path),x = xpos,y = ypos, clickable = click,visible = true,imageFunction = function()end}
	else	
		temp = {image = paintutils.loadImage(path),x = xpos,y = ypos, clickable = click,visible = true imageFunction = f}
	end
	Object.Images[itemNumber] = 
	{
		attributes = temp,
		draw = function()
			i = Objects.Images[itemNumber].attributes
			drawing.displayImage(i.image,i.x,i.y)
		end,
		getDimensions = function()
			i = Objects.Images[itemNumber].attributes
			x = 0
			y = #i.image
			for a=1,y,1 do
				x = math.max(x,#i[a])
			end
			return x,y
		end,
		clicked = function(xpos,ypos,executeF)--executeF tells the function whether or not to execute the image's function 
			i = Objects.Images[itemNumber].attributes
			local w,h = getDimensions(i)
			if(xpos>=i.x and xpos<=i.x+w-1) then
				if(ypos>=i.y and ypos<=i.y+h-1) then
					if(executeF)then
						i.imageFunction()
					end
					return true
				end
			end
			return false
		end,
		setVisibility = function(boolean)
			Objects.Images[itemNumber].attributes.visible = boolean
		end
	}
	return Object.Images[itemNumber]
end

function newDropDown(n,xpos,ypos,l,c,tc,ddc,ddtc)--Drop Down text, x position, y position, length, color, text color, drop down background color, drop down element text color, drop down visible?
	local itemNumber = #Objects.DropDowns+1
	Objects.DropDowns[itemNumber] = 
	{
		attributes = {name = n,x = xpos,y = ypos,length = l,color = c,textColor = tc, dropDownColor = ddc,dropDownTextColor = ddtc,visible = false,visible = true,elements = {}},
		addElement = function(n,f)
			d = Objects.DropDowns[itemNumber].attributes
			d.elements[#dd.elements+1] = {name = n,elementFunction = f}
		end,
		draw = function()
			d = Objects.DropDowns[itemNumber].attributes
			drawing.fillArea(d.color,d.x,d.y,d.length,1)
			drawing.writeText(d.name,d.x,d.y,d.color,d.textColor)
			if(d.visible)then
				drawing.fillArea(d.dropDownColor,d.x,d.y+1,d.length,#d.elements)
				for i=1,#d.elements,1 do
					drawing.writeText(d.elements[i].name,d.x,d.y+i,d.dropDownColor,d.dropDownTextColor)
				end
			end
		end,
		clicked = function(xpos,ypos,executeF)--executeF tells the function whether or not to execute the element's function 
			d = Objects.DropDowns[itemNumber].attributes
			if(xpos>=d.x and xpos<=d.x+d.length-1) then
				if(ypos==d.y) then
					d.visible = not d.visible
					return 0
				elseif (d.visible) then 	
					for a=1,#d.elements,1 do
						if(ypos==d.y+a and executeF) then
							d.elements[a].elementFunction()
							return a
						end
					end
				end
			end
			return -1
		end,
		setVisibility = function(boolean)
			Objects.DropDowns[itemNumber].attributes.visible = boolean
		end
	}
	return Objects.DropDowns[itemNumber]
end

function newScrollBar(xpos,ypos,l,ia,s,bgc,bc,ac,tc)-- x position, y position, length, number of items that are going to be scrolled through, is the scrollbar sideways?, background color for the scrollbar, bar color, end arrow background color, end arrow text color
	local itemNumber = #Objects.ScrollBars+1
	Objects.ScrollBars[itemNumber] = 
	{
		attributes =  {x = xpos,y = ypos,length = l,itemAmount = ia,sideWays = s,backGroundColor = bgc,barColor = bc,arrowColor = ac,textColor = tc,scroll = 0,visible = true},
		draw = function()
			s = Objects.ScrollBars[itemNumber].attributes
			if(s.sideWays)then
				drawing.fillArea(s.backGroundColor,s.x+1,s.y,s.length,1)
				drawing.writeText("<",s.x,s.y,s.arrowColor,s.textColor)
				drawing.writeText(">",s.x+s.length+1,s.y,s.arrowColor,s.textColor)
			else
				drawing.fillArea(s.backGroundColor,s.x,s.y+1,1,s.length)
				drawing.writeText("^",s.x,s.y,s.arrowColor,s.textColor)
				drawing.writeText("v",s.x,s.y+s.length+1,s.arrowColor,s.textColor)
			end
			local barLength = s.length
			if(s.itemAmount>=s.length*2-1)then
				barLength = 1
			elseif(s.itemAmount>=s.length)then
				barLength = s.length-(s.itemAmount-s.length)
			end
			term.setCursorPos(1,1)
			write(barLength)
			if(s.sideWays)then
				drawing.fillArea(s.barColor,s.x+s.scroll+1,s.y,s.x+barLength,1)
			else
				drawing.fillArea(s.barColor,s.x,s.y+s.scroll+1,1,s.y+barLength)
			end
		end,
		clicked = function(xpos,ypos)
			s = Objects.ScrollBars[itemNumber].attributes
			local barLength = s.length
			if(s.itemAmount>=s.length*2-1)then
				barLength = 1
			elseif(s.itemAmount>=s.length)then
				barLength = s.length-(s.itemAmount-s.length)
			end
			if(xpos==s.x) then
				if(ypos==s.y) then
					if(s.scroll>0)then
						s.scroll = s.scroll-1
					end
				end
			end
			if(xpos==s.x+s.length+1) then
				if(ypos==s.y) then
					if(s.scroll+barLength+1<s.length)then
						s.scroll = s.scroll+1
					end
				end
			end
			if(xpos==s.x) then
				if(ypos==s.y+s.length+1) then
					if(s.scroll+barLength+1<s.length)then
						s.scroll = s.scroll+1
					end
				end
			end
		end,
		setVisibility = function(boolean)
			Objects.ScrollBars[itemNumber].attributes.visible = boolean
		end
	}
	return Objects.ScrollBars[itemNumber]
end

function newProgressBar(xpos,ypos,l,dp,bc,bgc,tc)--x position, y position, length of the progress bar, if you want percentage use "*" else use string for text to be displayed in progress bar, percentage bar color, percentage bar background color, percentage text color
	local itemNumber = #Objects.ProgressBars+1
	Objects.ProgressBars[itemNumber] = 
	{
		attributes = {x = xpos,y = ypos,length = l,percentage = 0,progressText = dp,barColor = bc,backGroundColor = bgc,TextColor = tc,visible = true},
		updatePercentage = function(num)
			Objects.ProgressBars[itemNumber].attributes.percentage = num
		end,
		draw = function()
			p = Objects.ProgressBars[itemNumber].attributes
			drawing.fillArea(p.backGroundColor,p.x,p.y,p.length,1)
			drawing.fillArea(p.barColor,p.x,p.y,p.percentage/100*p.length,1)
			if(p.progressText=="*")then
				temp = tostring(p.percentage).."%"
			else
				temp = p.progressText
			end
			for i=1,#temp,1 do
				if(p.x+(p.length-#temp)/2+(i-1)<=p.percentage/100*p.length)then
					drawing.writeText(string.sub(temp,i,i),p.x+(p.length-#temp)/2+(i-1),p.y,p.barColor,p.TextColor)
				else
					drawing.writeText(string.sub(temp,i,i),p.x+(p.length-#temp)/2+(i-1),p.y,p.backGroundColor,p.TextColor)
				end
			end
			
		end,
		setVisibility = function(boolean)
			Objects.ProgressBars[itemNumber].attributes.visible = boolean
		end
	}
	return Objects.ProgressBars[itemNumber]
end

function newTextBox(xpos,ypos,w,h,text,m,c,tc,f)--x position, y position, width, height, text that will be displayed inside the text box, text mask i.e."*", color of the box, text color, function for what text box should do after user hits Enter
	local itemNumber = #Objects.TextBoxes+1
	local temp = {}
	for i=0,height,1 do
		temp[i] = ""
	end
	Objects.TextBoxes[itemNumber] = 
	{
		attributes = {x = xpos,y = ypos,width = w,height = h,displayText = text,mask = m,color = c,textColor = tc,text = temp,hasText = false,visible = true,endFunction = f},
		draw = function()
			t = Objects.TextBoxes[itemNumber].attributes
			drawing.fillArea(t.color,x,y,width,height)
			if(t.hasText) then
				for i=1,#n.text,1 do
					drawing.drawText(n.text[i],n.x+(i-1),n.y,n.color,n.textColor)
				end
			else
				drawing.writeText(t.displayText,t.x,t.y,t.color,t.textColor) 
			end
		end,
		clear = function()
			local temp = {}
			for i=0,height,1 do
				temp[i] = ""
			end
			Objects.TextBoxes[itemNumber].attributes.text = temp
			Objects.TextBoxes[itemNumber].attributes.hasText = false
		end,
		clicked = function(xpos,ypos)	
			local currentLine = 1
			n = Objects.TextBoxes[itemNumber].attributes
			if(n.x<=xpos and n.x+n.width>=xpos)then
				if(n.y<=ypos and n.y+n.height>=ypos)then
					term.setCursorBlink(true)
					while running do
						local event, p,pram1,pram2 = os.pullEvent()
						if(event == "char") then
							n.hasText = true
							for i=currentLine,n.height,1 do
								if(#n.text[i]<n.width)then
									n.text[i] = n.text[i]..p
								end
							end
						elseif(event == "key")then
							if p == keys.enter then
								n.endFunction()
								term.setCursorBlink(false)
								break
							elseif p == keys.backspace then
								n.text[currentLine] = n.text[currentLine]:sub(1, #n.text[currentLine] - 1)
								if(string.len(n.text[currentLine])==0)then
									if(currentLine>0)then        
										currentLine = currentLine-1
									end
								end
							end
						end
						Objects.TextBoxes[itemNumber].draw()
					end
				end
			end
		end,
		setVisibility = function(boolean)
			Objects.TextBoxes[itemNumber].attributes.visible = boolean
		end
	}
	
end

function newNotificationWindow(xpos,ypos,w,h,txt,t,button,functions)--x position, y position, width, height, notification text, title, button presets ["YesNo_option","OK_option","No_option"], button functions(place all functions inside of a table similar to notification text table) 
	local itemNumber = #Objects.NotificationWindows+1				--the text for a label is a table i.e. {"hello world" , "This is a test"} or {"hello world"}
	
	Objects.NotificationWindows[itemNumber] = 
	{
		attributes = {x = xpos,y = ypos,width = w,height = h,text = txt,title = t,buttonPreset = button,visible = false,visible = true,buttonFunctions = functions},
		draw = function()
			n = Objects.NotificationWindows[itemNumber].attributes
			if(n.visible)then
				drawing.fillArea(colors.lightGray,n.x,n.y,n.width,n.height)
				drawing.fillArea(colors.gray,n.x,n.y,n.width,1)
				drawing.drawText(n.title,n.x,n.y,colors.gray,colors.black)
				drawing.drawText(" X ",n.x+n.width-3,n.y,colors.red,colors.white)
				for i=0,#n.text,1 do
					drawing.writeText(n.text[i],n.x,n.y+i,colors.white,colors.lightGray)
				end
				if(n.buttonPresets=="YesNo_option")then
					drawing.drawText(" Yes ",n.x+(n.width/3)-2,n.y+n.height-1,colors.green,colors.white)
					drawing.drawText(" No ",n.x+(2*n.width/3)-2,n.y+n.height-1,colors.red,colors.white)
				elseif(n.buttonPresets=="OK_option")then
					drawing.drawText(" OK ",n.x+(n.width/2)-2,n.y+n.height-1,colors.green,colors.white)
				elseif(n.buttonPresets=="No_option")then
				end
			end
		end
		clicked  = function(xpos,ypos)
			n = Objects.NotificationWindows[itemNumber].attributes
			if(xpos>=n.x+n.width-3 and xpos<=n.x+n.width)then
				if(ypos==n.y)then
					n.visible = false
				end
			end
			if(n.buttonPreset=="YesNo_option")then
				if(ypos==n.y+n.height-1)then
					if(xpos>=n.x+(n.width/3)-2 and xpos<=n.x+(n.width/3)+2)then
						n.buttonFunctions[1]()
					elseif(xpos>=n.x+(2*n.width/3)-2 and xpos<=n.x+(2*n.width/3)+2)then
						n.buttonFunctions[2]()
					end
				end
			elseif(n.byuttonPreset=="OK_option")then
				if(ypos==n.y+n.height-1)then
					if(xpos>=n.x+(n.width/2)-2 and xpos<=n.x+(n.width/2)+2)then
						n.buttonFunctions[1]()
					end
				end
			end
		end,
		setVisibility = function(boolean)
			Objects.NotificationWindows[itemNumber].attributes.visible = boolean
		end
	}
end
