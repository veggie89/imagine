class window.Olive.QuotesView extends Olive.View
	id: 'quotes'
	className: "block"
	template: JST['quotes_view']
	collection: new Olive.Quote()
	events: ->
		"click .as_link": "remove_tag"
	remove_tag: (e) ->
		tag_name = $.trim $(e.currentTarget).text()
		$ele = $(e.currentTarget).parent()
		Utils.confirm "确认删除？", ->
			$.post "/olive/destroy_tag",tag: tag_name, (d) ->
				if d.status is 0
					$ele.remove()
					Utils.flash("#{d.data} removed")
	destroy_tag: ->
		$wrap = $("#tag_list",@$el)
		$form = $("form",$wrap)	
		$form.bind 'ajax:success', (d,data) ->
			if data.status is 0
				$form[0].reset()
				Utils.flash("#{data.data} removed")
	create: ->
		$wrap = $("#create",@$el)
		$form = $("form",$wrap)	
		$form.bind 'ajax:before',(d) ->
			Utils.loading $wrap
		$form.bind 'ajax:success', (d,data) ->
			if data.status is 0		
				Utils.flash(data.msg)
				$form[0].reset()
				Utils.loaded $wrap
	search: ->
		$wrap = $("#search",@$el)
		$form = $("form",$wrap)	
		$form.bind 'ajax:before',(d) ->
			Utils.loading $wrap
		$form.bind 'ajax:success', (d,data) ->
			$query = $("input[type='text']",$form).val()
			if data.status is 0		
				$("#quote_list").html JST['collection/quotes'](quotes: data.data.quotes,query: $query)
				$form[0].reset()
				Utils.loaded $wrap
	render: ->
		template = @template(tags: @collection.get('tags'))
		@$el.html(template)				
		this
	extra: ->
		@destroy_tag()
		@create()
		@search()
		super()