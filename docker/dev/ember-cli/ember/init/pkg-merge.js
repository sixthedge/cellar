var fs    = require('fs');
var merge = require('package-merge');
var _     = require('lodash')

var pkg_file = process.argv[2];

if (!( _.isString(pkg_file) )) {
  console.log('[ERROR] Package file is not a string.', pkg_file);
  process.exit(1);
}

var pkg_image    = fs.readFileSync('package.json');
var pkg_platform = fs.readFileSync(pkg_file);

var merged_pkg = merge(pkg_image, pkg_platform);

fs.writeFileSync('package.json', merged_pkg);

process.exit(0);
