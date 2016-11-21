$test = [{ key1 => 'val1', key2 => 'val2' },{ key1 => 'val1', key2 => 'val2' }]
include ::stdlib
notice (size($test))
