import React, { Component } from 'react';
import axios from 'axios';
import logo from './logo.svg';
import './App.css';

const V1_HAZARD_SEARCH_URL = process.env.REACT_APP_API_BASE_URL + "/api/v1/hazards/search";


class App extends Component {
  constructor(props) {
    super(props);
    this.state = { results: [] };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    let query = event.target.value;
    
    axios.get(V1_HAZARD_SEARCH_URL, {
      params: {
        q: query
      }
    }).then(res => {
      console.log(JSON.stringify(res.data));
      this.setState({ results: res.data.items });
    }).catch(err => {
      console.trace(err.message);
    });
  }
  
  render() {
    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to Hazard UI</h1>
        </header>
        <p className="App-intro">
          To get started, type "Hawaii".
        </p>
        <div className="container">
        <input type="text" onChange={this.handleChange} />
        <SearchResults results={this.state.results} />
        </div>
      </div>      
    );
  }
}

class SearchResults extends Component {
  render() {
    const results = this.props.results || [];
    let items = results.map(item => {
      return (
          <li key={item.toString()}>{item}</li>
      );
    });
    return (
      <div className="search_results">
        <hr />
        <ul>
        {
          items
        }
        </ul>
      </div>
    );
  }
}

export default App;
