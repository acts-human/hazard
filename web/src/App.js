import React, { Component } from 'react';
import elasticsearch from "elasticsearch";
import logo from './logo.svg';
import './App.css';

let client = new elasticsearch.Client({
  host: "localhost:9200",
  log: "trace"
});

class App extends Component {
  constructor(props) {
    super(props);
    this.state = { results: [] };
    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    const search_query = event.target.value;
    client
      .search({
        index: 'earthquake',
        q: search_query
      })
      .then(
        function(body) {
          console.log(body);
          this.setState({ results: body.hits.hits });
        }.bind(this),
        function(error) {
          console.trace(error.message);
        }
      );
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

    return (
      <div className="search_results">
        <hr />
        <ul>
        {results.map(result => {
          return (
            <li key={result._id}>
              {result._source.magnitude} {result._source.place}
            </li>
          );
        })}
        </ul>
      </div>
    );
  }
}

export default App;
