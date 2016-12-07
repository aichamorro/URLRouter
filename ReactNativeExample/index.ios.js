/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  TouchableHighlight,
  TextInput,
  View
} from 'react-native';

import { NativeModules } from 'react-native';
var URLRouter = NativeModules.ReactNativeURLRouter;
URLRouter.open("app://user/3/", (error, result) => {
  if (error) {
    console.error(error);
  } else {
    console.log(result);
  }
})

export default class ReactNativeExample extends Component {
  constructor(props) {
    super(props);
    this.state = {text: 'Result: Undefined', query:"app://user/3/"}
  }

  _onPressButton() {
    URLRouter.open(this.state.query, (error, result) => {
      var resultText = 'Result: ' + (error ? '[Error] ' + error : result);
      this.setState({text: resultText})
    })
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={{alignSelf: 'stretch', marginLeft: 20}}>{this.state.text}</Text>
        <TextInput style={{height: 40, marginLeft: 20, marginRight: 20, fontSize: 15, color: 'grey', backgroundColor: 'white'}}
            autoCapitalize='none'
            autoCorrect={false}
            placeholder='app://user/3/'
            onChange={(event) => this.setState({query: event.nativeEvent.text})}></TextInput>
        <TouchableHighlight onPress={this._onPressButton.bind(this)} style={{marginTop: 10, backgroundColor: 'orange', marginLeft: 20, marginRight: 20, alignSelf: 'stretch'}}>
          <Text style={{textAlign: 'center', paddingTop: 5, paddingBottom: 5}}>Go!</Text>
        </TouchableHighlight>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});

AppRegistry.registerComponent('ReactNativeExample', () => ReactNativeExample);
