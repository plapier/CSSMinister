" =============================================================================
" File:          CSSMinister.vim
" Maintainer:    Luis Gonzalez <kuroi_kenshi96 at yahoo dot com>
" Description:   Easy modification of colors in CSS stylesheets. Change colors
"                from one format to another. Currently supported formats include
"                hex, RGB and HSL.
" Last Modified: March 19, 2010
" License:       GPL (see http://www.gnu.org/licenses/gpl.txt)
"
" TODO: visual mode conversions 
" TODO: rgba and hsla conversions
" TODO: fix slow execution time when converting one color at a time
" TODO: alt. delimeters for mappings
" =============================================================================
"
" Editor:        Phil LaPier - http://lapier.me
" Last Modified: Sept 19, 2011


" Script init stuff {{{1
if exists("g:CSSMinister_version") || &cp
    finish
endif

let g:CSSMinister_version = "0.2.1"


" Constants {{{1
let s:RGB_NUM_RX    = '\v\crgb\(([01]?\d\d?|2[0-4]\d|25[0-5]),\s*([01]?\d\d?|2[0-4]\d|25[0-5]),\s*([01]?\d\d?|2[0-4]\d|25[0-5])\);?'
let s:RGBA_NUM_RX   = '\v\crgba\(([01]?\d\d?|2[0-4]\d|25[0-5]),\s*([01]?\d\d?|2[0-4]\d|25[0-5]),\s*([01]?\d\d?|2[0-4]\d|25[0-5]),\s*(\d(\.\d{1,3})?)\);?'
let s:RGB_PERC_RX   = '\v\crgb\((\d\%|[1-9]{1}[0-9]\%|100\%),\s*(\d\%|[1-9]{1}[0-9]\%|100\%),\s*(\d\%|[1-9]{1}[0-9]\%|100\%)\);?'
let s:RGBA_PERC_RX  = '\v\crgba\((\d\%|[1-9]{1}[0-9]\%|100\%),\s*(\d\%|[1-9]{1}[0-9]\%|100\%),\s*(\d\%|[1-9]{1}[0-9]\%|100\%),\s*(\d{1}(\.\d{1,3})?)\);?'
let s:RGB_DISCOVERY = '\v\crgb\(\d+.*,\s*\d+.*,\s*\d+.*\);?'
let s:HSL           = '\vhsl\((-?\d+),\s*(\d\%|[1-9][0-9]\%|100\%),\s*(\d\%|[1-9][0-9]\%|100\%)\);?'
let s:HSLA          = '\vhsla\((-?\d+),\s*(\d\%|[1-9][0-9]\%|100\%),\s*(\d\%|[1-9][0-9]\%|100\%),\s*((\d+)?(\.\d{1,2})?)\);?'
let s:HEX           = '\v([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})'
let s:HEX_DISCOVERY = '\v#[0-9a-fA-F]{3,6}'
let s:W3C_COLOR_RX  = '\v\c(black|silver|gray|white(-space)@!|maroon|red|purple|fuchsia|green|lime|olive|yellow|navy|blue|teal|aqua)'

let s:W3C_COLORS = { 'black':   '#000000',
		   \ 'silver':  '#C0C0C0',
		   \ 'gray':    '#808080',
		   \ 'white':   '#FFFFFF',
		   \ 'maroon':  '#800000',
		   \ 'red':     '#FF0000',
		   \ 'purple':  '#800080',
		   \ 'fuchsia': '#FF00FF', 
		   \ 'green':   '#008000',
		   \ 'lime':    '#00FF00',
		   \ 'olive':   '#808000',
		   \ 'yellow':  '#FFFF00',
		   \ 'navy':    '#000080',
		   \ 'blue':    '#0000FF',
		   \ 'teal':    '#008080',
		   \ 'aqua':    '#00FFFF' }


let g:CSSMinisterCreateMappings = 1


" Public API {{{1
" Mappings {{{2
function! s:CreateMappings(target, mapping)
    if !hasmapto(a:mapping, 'n')
        exec 'nmap ' . a:mapping . ' ' . a:target
    endif
endfunction


if g:CSSMinisterCreateMappings
   call s:CreateMappings('<Plug>CSSMinisterHexToRGB',        ',xr')
   call s:CreateMappings('<Plug>CSSMinisterHexToRGBA',       ',xra')
   call s:CreateMappings('<Plug>CSSMinisterHexToRGBAll',     ',axr')
   call s:CreateMappings('<Plug>CSSMinisterHexToHSL',        ',xh')
   call s:CreateMappings('<Plug>CSSMinisterHexToHSLA',       ',xha')
   call s:CreateMappings('<Plug>CSSMinisterHexToHSLAll',     ',axh')
   call s:CreateMappings('<Plug>CSSMinisterRGBToRGBA',       ',ra')
   call s:CreateMappings('<Plug>CSSMinisterRGBToHex',        ',rx')
   call s:CreateMappings('<Plug>CSSMinisterRGBToHexAll',     ',arx')
   call s:CreateMappings('<Plug>CSSMinisterRGBToHSL',        ',rh')
   call s:CreateMappings('<Plug>CSSMinisterRGBToHSLA',       ',rha')
   call s:CreateMappings('<Plug>CSSMinisterRGBToHSLAll',     ',arh')
   call s:CreateMappings('<Plug>CSSMinisterRGBAToHSLA',      ',raha')
   call s:CreateMappings('<Plug>CSSMinisterHSLToHex',        ',hx')
   call s:CreateMappings('<Plug>CSSMinisterHSLToHexAll',     ',ahx')
   call s:CreateMappings('<Plug>CSSMinisterHSLToRGB',        ',hr')
   call s:CreateMappings('<Plug>CSSMinisterHSLToHSLA',       ',ha')
   call s:CreateMappings('<Plug>CSSMinisterHSLToRGBA',       ',hra')
   call s:CreateMappings('<Plug>CSSMinisterHSLToRGBAll',     ',ahr')
   call s:CreateMappings('<Plug>CSSMinisterHSLAToRGBA',      ',hara')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToHex',    ',kx')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToHexAll', ',akx')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToRGB',    ',kr')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToRGBAll', ',akr')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToHSL',    ',kh')
   call s:CreateMappings('<Plug>CSSMinisterKeywordToHSLAll', ',akh')

   let g:CSSMinisterCreateMappings = 0
endif


noremap <silent> <script> <Plug>CSSMinisterHexToRGB        :call MinisterConvert('hex', 'rgb')<CR>
noremap <silent> <script> <Plug>CSSMinisterHexToRGBA       :call MinisterConvert('hex', 'rgba')<CR>
noremap <silent> <script> <Plug>CSSMinisterHexToRGBAll     :call MinisterConvert('hex', 'rgb', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterHexToHSL        :call MinisterConvert('hex', 'hsl')<CR>
noremap <silent> <script> <Plug>CSSMinisterHexToHSLA       :call MinisterConvert('hex', 'hsla')<CR>
noremap <silent> <script> <Plug>CSSMinisterHexToHSLAll     :call MinisterConvert('hex', 'hsl', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToRGBA       :call MinisterConvert('rgb', 'rgba')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToHex        :call MinisterConvert('rgb', 'hex')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToHexAll     :call MinisterConvert('rgb', 'hex', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToHSL        :call MinisterConvert('rgb', 'hsl')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToHSLA       :call MinisterConvert('rgb', 'hsla')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBToHSLAll     :call MinisterConvert('rgb', 'hsl', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterRGBAToHSLA      :call MinisterConvert('rgba', 'hsla')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToHex        :call MinisterConvert('hsl', 'hex')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToHexAll     :call MinisterConvert('hsl', 'hex', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToHSLA       :call MinisterConvert('hsl', 'hsla')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToRGB        :call MinisterConvert('hsl', 'rgb')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToRGBA       :call MinisterConvert('hsl', 'rgba')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLToRGBAll     :call MinisterConvert('hsl', 'rgb', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterHSLAToRGBA      :call MinisterConvert('hsla', 'rgba')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToHex    :call MinisterConvert('keyword', 'hex')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToHexAll :call MinisterConvert('keyword', 'hex', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToRGB    :call MinisterConvert('keyword', 'rgb')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToRGBAll :call MinisterConvert('keyword', 'rgb', 'all')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToHSL    :call MinisterConvert('keyword', 'hsl')<CR>
noremap <silent> <script> <Plug>CSSMinisterKeywordToHSLAll :call MinisterConvert('keyword', 'hsl', 'all')<CR>
"}}}2


" -----------------------------------------------------------------------------
" Convert: Wrapper for all conversion functions
" Args:
"   from:  format we're converting from
"   to:    format we're converting to
"   {all}: specify whether to convert the next matching color or all colors in 
"          buffer
function! MinisterConvert(from, to, ...)
    if a:from == a:to | return | endif
    let all = a:0 >= 1 ? a:1 : ''

    if a:from =~ '\vhex|rgb|rgba|hsl|hsla|keyword'
        if all == 'all'
            call s:ReplaceAll(a:from, a:to)
        else 
            call s:ReplaceNext(a:from, a:to)
        endif
    endif
endfunction


" -----------------------------------------------------------------------------
" ToRGB: Converts colors in hex or hsl format to rgb
function! ToRGB(from_format)
    if s:IsHex(a:from_format)
        return s:HexToRGB(a:from_format)
    elseif s:IsHSL(a:from_format)
        return s:HSLToRGB(a:from_format)
    elseif s:IsKeyword(a:from_format)
        return s:HexToRGB(ToHex(a:from_format))
    endif
endfunction


" -----------------------------------------------------------------------------
" ToRGBA: Converts colors in hex or hsl format to rgb
function! ToRGBA(from_format)
    if s:IsHex(a:from_format)
        return s:HexToRGBA(a:from_format)
    elseif s:IsHSL(a:from_format)
        return s:HSLToRGBA(a:from_format)
    elseif s:IsHSLA(a:from_format)
        return s:HSLAToRGBA(a:from_format)
    elseif s:IsRGB(a:from_format)
        return s:RGBToRGBA(a:from_format)
    elseif s:IsKeyword(a:from_format)
        return s:HexToRGBA(ToHex(a:from_format))
    endif
endfunction


" -----------------------------------------------------------------------------
" ToHSL: Converts colors in hex or rgb format to hsl
function! ToHSL(from_format)
    if s:IsHex(a:from_format)
        let rgb = s:HexToRGB(a:from_format)
        return s:RGBToHSL(rgb)
    elseif s:IsRGB(a:from_format)
        return s:RGBToHSL(a:from_format)
    elseif s:IsKeyword(a:from_format)
        let rgb = s:HexToRGB(ToHex(a:from_format))
        return s:RGBToHSL(rgb)
    endif
endfunction


" -----------------------------------------------------------------------------
" ToHSLA: Converts colors in hex or rgb format to hsl
function! ToHSLA(from_format)
    if s:IsHex(a:from_format)
        let rgb = s:HexToRGB(a:from_format)
        return s:RGBToHSLA(rgb)
    elseif s:IsRGB(a:from_format)
        return s:RGBToHSLA(a:from_format)
    elseif s:IsHSL(a:from_format)
        return s:HSLToHSLA(a:from_format)
    elseif s:IsKeyword(a:from_format)
        let rgb = s:HexToRGB(ToHex(a:from_format))
        return s:RGBToHSLA(rgb)
    endif
endfunction


" -----------------------------------------------------------------------------
" ToHex: Converts colors in rgb or hsl format to hex
function! ToHex(from_format)
    if s:IsRGB(a:from_format)
        return s:RGBToHex(a:from_format)
    elseif s:IsHSL(a:from_format)
        let rgb = s:HSLToRGB(a:from_format)
        return s:RGBToHex(rgb)
    elseif s:IsKeyword(a:from_format)
	return s:KeywordToHex(a:from_format)
    endif
endfunction


" Format verification functions {{{1
" -----------------------------------------------------------------------------
" Assumes the color being passed in is of the these formats:
"   rgb(0, 70, 255); 
"   rgb(0%, 50%, 100%);
function! s:IsRGB(color)
    return a:color =~ s:RGB_NUM_RX || a:color =~ s:RGB_PERC_RX
endfunction

function! s:IsRGBA(color)
    return a:color =~ s:RGBA_NUM_RX || a:color =~ s:RGBA_PERC_RX
endfunction

function! s:IsHSL(color)
    return a:color =~ s:HSL
endfunction

function! s:IsHSLA(color)
    return a:color =~ s:HSLA
endfunction

function! s:IsHex(color)
    return a:color =~ s:HEX_DISCOVERY
endfunction

function! s:IsKeyword(color)
    return has_key(s:W3C_COLORS, a:color)
endfunction


" -----------------------------------------------------------------------------
" Color to RGB conversion {{{1
function! s:HexToRGB(hex)
    if strlen(a:hex) == 7
        let color = matchlist(a:hex, '\v([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})')
        return s:OutputRGB(color[1], color[2], color[3])
    elseif strlen(a:hex) == 4
        let color = split(a:hex, '\zs')
        return s:OutputRGB(repeat(color[1], 2), repeat(color[2],2), repeat(color[3], 2))
    endif
endfunction


" -----------------------------------------------------------------------------
" Color to RGBA conversion {{{1
function! s:HexToRGBA(hex)
    if strlen(a:hex) == 7
        let color = matchlist(a:hex, '\v([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})')
        return s:OutputRGBA(color[1], color[2], color[3], '1.0')
    elseif strlen(a:hex) == 4
        let color = split(a:hex, '\zs')
        return s:OutputRGBA(repeat(color[1], 2), repeat(color[2],2), repeat(color[3], 2), '1.0')
    endif
endfunction


" -----------------------------------------------------------------------------
" s:HSLToRGB: http://www.easyrgb.com/index.php?X=MATH&H=19#text19 
function! s:HSLToRGB(hsl)
    let match = matchlist(a:hsl, s:HSL)
    " the next expression normalizes the angle into the 0-360 range
    " see: http://www.w3.org/TR/css3-color/#hsl-color
    let h = match[1] >= 0 && match[1] <= 360 ? match[1]/360.0 : (((match[1] % 360) + 360) % 360)/360.0
    let s = match[2]/100.0
    let l = match[3]/100.0

    let rgb = {}
    if s == 0
        let [rgb.r, rgb.g, rgb.b] = map([l, l, l], 'v:val * 255')
    else
        let var_2 = l < 0.5 ? l * (1.0 + s) : (l + s) - (s * l)
        let var_1 = 2 * l - var_2

        let rgb.r = s:Hue2RGB(var_1, var_2, h + (1.0/3))
        let rgb.g = s:Hue2RGB(var_1, var_2, h)
        let rgb.b = s:Hue2RGB(var_1, var_2, h - (1.0/3))

        let rgb = map(rgb, 'v:val * 255')
    endif

    return 'rgb(' . float2nr(rgb.r) . ', ' . float2nr(rgb.g) . ', ' . float2nr(rgb.b) . ')'
endfunction



" -----------------------------------------------------------------------------
" s:HSLToRGBA: http://www.easyrgb.com/index.php?X=MATH&H=19#text19 
function! s:HSLToRGBA(hsl)
    let match = matchlist(a:hsl, s:HSL)
    " the next expression normalizes the angle into the 0-360 range
    " see: http://www.w3.org/TR/css3-color/#hsl-color
    let h = match[1] >= 0 && match[1] <= 360 ? match[1]/360.0 : (((match[1] % 360) + 360) % 360)/360.0
    let s = match[2]/100.0
    let l = match[3]/100.0

    let rgb = {}
    if s == 0
        let [rgb.r, rgb.g, rgb.b] = map([l, l, l], 'v:val * 255')
    else
        let var_2 = l < 0.5 ? l * (1.0 + s) : (l + s) - (s * l)
        let var_1 = 2 * l - var_2

        let rgb.r = s:Hue2RGB(var_1, var_2, h + (1.0/3))
        let rgb.g = s:Hue2RGB(var_1, var_2, h)
        let rgb.b = s:Hue2RGB(var_1, var_2, h - (1.0/3))

        let rgb = map(rgb, 'v:val * 255')
    endif

    return 'rgba(' . float2nr(rgb.r) . ', ' . float2nr(rgb.g) . ', ' . float2nr(rgb.b) . ', 1.0)'
endfunction


" -----------------------------------------------------------------------------
" s:HSLAToRGBA: http://www.easyrgb.com/index.php?X=MATH&H=19#text19 
function! s:HSLAToRGBA(hsla)
    let match = matchlist(a:hsla, s:HSLA)
    " the next expression normalizes the angle into the 0-360 range
    " see: http://www.w3.org/TR/css3-color/#hsl-color
    let h = match[1] >= 0 && match[1] <= 360 ? match[1]/360.0 : (((match[1] % 360) + 360) % 360)/360.0
    let s = match[2]/100.0
    let l = match[3]/100.0
    let a = match[4]

    let match = map(match, 'str2nr(v:val)')

    let rgba = {}
    if s == 0
        let [rgba.r, rgba.g, rgba.b] = map([l, l, l], 'float2nr(v:val * 255)')
        let rgba.a = a
        let rgba = map(rgba, 'v:val')
    else
        let var_2 = l < 0.5 ? l * (1.0 + s) : (l + s) - (s * l)
        let var_1 = 2 * l - var_2

        let rgba.r = s:Hue2rgba(var_1, var_2, h + (1.0/3))
        let rgba.g = s:Hue2rgba(var_1, var_2, h)
        let rgba.b = s:Hue2rgba(var_1, var_2, h - (1.0/3))
        let rgba.a = a

        let rgba = map(rgb, 'v:val * 255')
        let rgba = map(rgba)
    endif

    return 'rgba(' . float2nr(rgba.r) . ', ' . float2nr(rgba.g) . ', ' . float2nr(rgba.b) . ', ' . rgba.a . ')'
endfunction



" s:HSLToHSLA:
function! s:HSLToHSLA(hsl)
    let match = matchlist(a:hsl, s:HSL)
    let h = match[1]
    let s = match[2]
    let l = match[3]

    let hsl= {}
    let [hsl.h, hsl.s, hsl.l] = match[1:3]

    return 'hsla(' . hsl.h . ', ' . hsl.s . ', ' . hsl.l . ', 1.0)'
endfunction



" -----------------------------------------------------------------------------
" s:Hue2RGB: http://www.easyrgb.com/index.php?X=MATH&H=19#text19 
function! s:Hue2RGB(v1, v2, vH)
    let H = a:vH
    if H < 0 | let H += 1 | endif
    if H > 1 | let H -= 1 | endif
    if (6 * H) < 1 | return a:v1 + (a:v2 - a:v1) * 6 * H | endif
    if (2 * H) < 1 | return a:v2 | endif
    if (3 * H) < 2 | return a:v1 + (a:v2 - a:v1) * ((2.0/3) - H) * 6 | endif 
    return a:v1
endfunction

function! s:OutputRGB(r, g, b)
    return 'rgb(' . printf('%d', '0x' . a:r) . ', ' . printf('%d', '0x' . a:g) . ', ' . printf('%d', '0x' . a:b) . ')'
endfunction

function! s:OutputRGBA(r, g, b, a)
    return 'rgba(' . printf('%d', '0x' . a:r) . ', ' . printf('%d', '0x' . a:g) . ', ' . printf('%d', '0x' . a:b) . ', ' . printf('%.1f', '0x' . a:a + 0.0) . ')'
endfunction


" Only works with non-percent RGB values
" s:RGBToRGBA:
function! s:RGBToRGBA(rgb)
    let norm_rgb = matchlist(a:rgb, s:RGB_NUM_RX)
    let r = norm_rgb[1]
    let g = norm_rgb[2]
    let b = norm_rgb[3]

    let rgb= {}
    let [rgb.r, rgb.g, rgb.b] = norm_rgb[1:3]

    return 'rgba(' . rgb.r . ', ' . rgb.g . ', ' . rgb.b . ', 1.0)'
endfunction



" Color to HSL conversion {{{1
" -----------------------------------------------------------------------------
" s:RGBToHSL: http://www.easyrgb.com/index.php?X=MATH&H=18#text18
" Args:
"   rgb: A string representing a color in RGB format, i.e. 'hsl(0, 50%, 100%)'
function! s:RGBToHSL(rgb)
    " normalize rgb values - they can be in either the range 0-255 or 0-100%
    let norm_rgb = matchlist(a:rgb, s:RGB_PERC_RX)
    if empty(norm_rgb)
        let norm_rgb = matchlist(a:rgb, s:RGB_NUM_RX)
        let norm_rgb = map(norm_rgb, 'str2nr(v:val)')
    else 
        " strip off the %'s
        let norm_rgb = map(norm_rgb, 'str2nr(v:val)')
        let norm_rgb = map(norm_rgb, 'v:val*255')
    endif
    
    let rgb_dict = {}
    let [rgb_dict.r, rgb_dict.g, rgb_dict.b] = norm_rgb[1:3]

    let min = min(rgb_dict)/255.0
    let max = max(rgb_dict)/255.0
    let delta = (max - min)

    let rgb_dict = map(rgb_dict, 'v:val/255.0')

    let hsl = {}
    let hsl.l = ( max + min )/2.0

    if delta == 0
        let [hsl.h, hsl.s] = [0, 0]
    else 
        let hsl.s = hsl.l < 0.5 ? delta/(max + min + 0.0) : delta/(2.0 - max - min)

        let delta_rgb = {}
        let delta_r = (((max - rgb_dict.r)/6.0) + (delta/2.0))/delta
        let delta_g = (((max - rgb_dict.g)/6.0) + (delta/2.0))/delta
        let delta_b = (((max - rgb_dict.b)/6.0) + (delta/2.0))/delta

        if rgb_dict.r == max 
            let hsl.h = delta_b - delta_g
        elseif rgb_dict.g == max 
            let hsl.h = (1/3.0) + delta_r - delta_b
        elseif rgb_dict.b == max 
            let hsl.h = (2/3.0) + delta_g - delta_r
        endif

        if hsl.h < 0 | let hsl.h += 1 | endif
        if hsl.h > 1 | let hsl.h -= 1 | endif
    endif

    return s:OutputHSL(hsl)
endfunction


" Color to HSL conversion {{{1
" -----------------------------------------------------------------------------
" s:RGBToHSLA: http://www.easyrgb.com/index.php?X=MATH&H=18#text18
" Args:
"   rgb: A string representing a color in RGB format, i.e. 'hsl(0, 50%, 100%)'
function! s:RGBToHSLA(rgb)
    " normalize rgb values - they can be in either the range 0-255 or 0-100%
    let norm_rgb = matchlist(a:rgb, s:RGB_PERC_RX)
    if empty(norm_rgb)
        let norm_rgb = matchlist(a:rgb, s:RGB_NUM_RX)
        let norm_rgb = map(norm_rgb, 'str2nr(v:val)')
    else 
        " strip off the %'s
        let norm_rgb = map(norm_rgb, 'str2nr(v:val)')
        let norm_rgb = map(norm_rgb, 'v:val*255')
    endif
    
    let rgb_dict = {}
    let [rgb_dict.r, rgb_dict.g, rgb_dict.b] = norm_rgb[1:3]

    let min = min(rgb_dict)/255.0
    let max = max(rgb_dict)/255.0
    let delta = (max - min)

    let rgb_dict = map(rgb_dict, 'v:val/255.0')

    let hsl = {}
    let hsl.l = ( max + min )/2.0

    if delta == 0
        let [hsl.h, hsl.s] = [0, 0]
    else 
        let hsl.s = hsl.l < 0.5 ? delta/(max + min + 0.0) : delta/(2.0 - max - min)

        let delta_rgb = {}
        let delta_r = (((max - rgb_dict.r)/6.0) + (delta/2.0))/delta
        let delta_g = (((max - rgb_dict.g)/6.0) + (delta/2.0))/delta
        let delta_b = (((max - rgb_dict.b)/6.0) + (delta/2.0))/delta

        if rgb_dict.r == max 
            let hsl.h = delta_b - delta_g
        elseif rgb_dict.g == max 
            let hsl.h = (1/3.0) + delta_r - delta_b
        elseif rgb_dict.b == max 
            let hsl.h = (2/3.0) + delta_g - delta_r
        endif

        if hsl.h < 0 | let hsl.h += 1 | endif
        if hsl.h > 1 | let hsl.h -= 1 | endif
    endif

    return s:OutputHSLA(hsl)
endfunction



" -----------------------------------------------------------------------------
" s:OutputHSL: Outputs a formatted string in hsl format.
" Args:
"   hsl: Dictionary with h, s, l keys. Their values are normalized in order to
"        return a valid formatted string. 
function! s:OutputHSL(hsl)
    let temp_hsl = a:hsl
    let temp_hsl.h = float2nr( temp_hsl.h * 360.0 )
    let [temp_hsl.s, temp_hsl.l] = map([temp_hsl.s, temp_hsl.l], "float2nr(round(v:val * 100)) . '%'")
    return 'hsl(' . temp_hsl.h . ', ' . temp_hsl.s . ', ' . temp_hsl.l . ')'
endfunction


" -----------------------------------------------------------------------------
" s:OutputHSLA: Outputs a formatted string in hsl format.
" Args:
"   hsl: Dictionary with h, s, l keys. Their values are normalized in order to
"        return a valid formatted string. 
function! s:OutputHSLA(hsl)
    let temp_hsl = a:hsl
    let temp_hsl.h = float2nr( temp_hsl.h * 360.0 )
    let [temp_hsl.s, temp_hsl.l] = map([temp_hsl.s, temp_hsl.l], "float2nr(round(v:val * 100)) . '%'")
    return 'hsla(' . temp_hsl.h . ', ' . temp_hsl.s . ', ' . temp_hsl.l . ', 1.0)'
endfunction



" -----------------------------------------------------------------------------
"
" Color to Hex conversion {{{1
" s:RGBToHex: Converts a color from functional notation to its hex equivalent.
" Args:
"   rgb: A color in RGB format
function! s:RGBToHex(rgb)
    let t_rgb = {}
    " figure out if 3 integer or 3 percent values are used
    let color = a:rgb =~ s:RGB_NUM_RX ? matchlist(a:rgb, s:RGB_NUM_RX) : matchlist(a:rgb, s:RGB_PERC_RX)
    let [t_rgb.r, t_rgb.g, t_rgb.b] = color[1:3]
    return s:ToHex(t_rgb)
endfunction


" -----------------------------------------------------------------------------
function! s:GetHexValue(val)
    let hex_values = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'A', 'B', 'C', 'D', 'E', 'F']
    let n = max([0, a:val])
    let n = min([a:val, 255])
    let n = float2nr(round(n))
    return printf('%s', hex_values[(n-n%16)/16]) . printf('%s', hex_values[n%16])
endfunction


" -----------------------------------------------------------------------------
function! s:ToHex(rgb)
    return '#' . s:GetHexValue(a:rgb.r) . s:GetHexValue(a:rgb.g) . s:GetHexValue(a:rgb.b)
endfunction


" -----------------------------------------------------------------------------
function! s:KeywordToHex(kw)
    return s:W3C_COLORS[a:kw]
endfunction



" Replacement functions {{{1
" -----------------------------------------------------------------------------
" s:ReplaceAll: Replaces all colors in the current buffer to the requested
"               color format.
" Args:
"   from: the color format we're converting from
"   to:   the color format we're converting to
function! s:ReplaceAll(from, to)
    let lines = getbufline('%', 1, '$')
    let regex = ''
    if a:from == 'hex'
        let regex = s:HEX_DISCOVERY
    elseif a:from == 'rgb'
        let regex = s:RGB_DISCOVERY
    elseif a:from == 'hsl'
        let regex = s:HSL
    endif

    let matchingLines = filter(copy(lines), "v:val =~ regex")
    
    for line in matchingLines
        let lineNum = index(lines, line) + 1
        let convert = s:ReplacementPairings(a:from, a:to)

        let replace = substitute(line, convert.from_rx, '\=To' . convert.to . '(submatch(0))', 'g')

        " prevent replacing the first matching line if there are more than one 
        " identical color declarations on separate lines
        let lines[lineNum - 1] = ''

        call setline(lineNum, replace)
    endfor
endfunction


" -----------------------------------------------------------------------------
" s:ReplaceNext: Replaces the next matching color to one in the requested
"                format in the current buffer.
" Args:
"   from: the color format we're converting from
"   to:   the color format we're converting to
function! s:ReplaceNext(from, to)
    let lineNum = line('.')
    let line = getline('.')
    let convert = s:ReplacementPairings(a:from, a:to)

    let line = substitute(line, convert.from_rx, '\=To' . convert.to . '(submatch(0))', '')

    call setline(lineNum, line)
endfunction


" -----------------------------------------------------------------------------
" s:ReplacementPairings: Returns a dictionary with two regex's: one for
"                        retrieving matching colors according to the format 
"                        given, and another for replacing them to the 
"                        requested format.
" Args:
"   from: the color format we're converting from
"   to:   the color format we're converting to
function! s:ReplacementPairings(from, to)
    let pairings = {}
    let from_rx_mappings = { 'rgb': s:RGB_NUM_RX . '|' . strpart(s:RGB_PERC_RX, 4, strlen(s:RGB_PERC_RX)), 
                           \ 'rgba': s:RGBA_NUM_RX . '|' . strpart(s:RGBA_PERC_RX, 4, strlen(s:RGBA_PERC_RX)), 
                           \ 'hsl': s:HSL, 
                           \ 'hsla': s:HSLA, 
                           \ 'hex': s:HEX_DISCOVERY, 
                           \ 'keyword': s:W3C_COLOR_RX }

    if a:to == 'hex' | let pairings.to = 'Hex' |
    \ elseif a:to == 'rgb' || a:to == 'rgba' || a:to == 'hsl' || a:to == 'hsla' | let pairings.to = toupper(a:to) | endif

    let pairings.from_rx = from_rx_mappings[a:from]

    return pairings
endfunction



" vim:ft=vim foldmethod=marker sw=4
"
