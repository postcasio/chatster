$(function() {
	$(document).on('click', '.vote-link', function() {
		var $this = $(this), path;
		var id = $this.data('id');
		if ($this.is('.vote-down')) {
			path = '/vote/' + id + '/down';
		}
		else {
			path = '/vote/' + id + '/up';
		}
		
		$.get(path, function(response) {
			location.reload();
		});
		
		return false;
	});
});