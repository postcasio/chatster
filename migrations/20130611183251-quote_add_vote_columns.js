module.exports = {
	up: function(migration, DataTypes, done) {
		migration.removeColumn('Quotes', 'created_at');
		migration.addColumn('Quotes', 'votes_up', DataTypes.INTEGER);
		migration.addColumn('Quotes', 'votes_down', DataTypes.INTEGER);
	},
	
	down: function(migration, DataTypes, done) {
		migration.addColumn('Quotes', 'created_at', DataTypes.DATE);
		migration.removeColumn('Quotes', 'votes_up');
		migration.removeColumn('Quotes', 'votes_down');
	}
}