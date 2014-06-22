app = angular.module 'app', []

app.controller 'Ctrl', ['$scope', '$http', ($scope, $http) ->
  $scope.init = ->
    $scope.query = ""
    $scope.results = []
    $scope.index_test_result = ''

  $scope.submit = ->
    $scope.results = [path: "Loading", meta: {"Loading": "Loading"}]
    $http.get("/api/search/#{$scope.query}")
      .success (data) ->
        $scope.results = data.results
      .error (err) ->
        console.log "Error : ", err

  $scope.index_test = ->
    $http.get('/api/index_test')
      .success (data) ->
        $scope.index_test_result = data
      .error (err) ->
        $scope.index_test_result = err

  $scope.delete_test = ->
    $http.get('/api/delete_test')
      .success (data) ->
        $scope.delete_test_result = data
      .error (err) ->
        $scope.delete_test_result = err
]
