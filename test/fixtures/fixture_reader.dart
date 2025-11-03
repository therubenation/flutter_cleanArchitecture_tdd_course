/// fixtures: test-daten für reproduzierbare, offline tests.
/// fixtures enthält “eingefrorene” jsons, damit tests stabil sind (kein netz, keine api-schwankungen)
/// mimics the JSON response from the API

import 'dart:io';

String fixture(String name) =>
    File('test/fixtures/$name').readAsStringSync(); // what happens here ?
