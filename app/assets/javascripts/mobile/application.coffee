#= require_tree ./lib
#= require hamlcoffee
#= require underscore
#= require backbone
#= require_tree ./templates
#= require_tree ./backbone/models
#= require ./backbone/mobile

$ ->
	new Mobile()