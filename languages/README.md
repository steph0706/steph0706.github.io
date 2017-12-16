Stephanie Wong, Vincent Tran

We both did research and found datasets to support our ideas. Data was excruciatingly painful to collect. Steph had to scrape pdfs because Ethnologue doesn't give their data out for free. While we both had great ideas for the mission of this project, it was hard to find the exact data to support our knowledge, so Vincent had to do a lot of data manipulation (writing scripts and whatnot) to organize the data in a presentable way. Working with the react-vis library alone was a bit difficult due to the youth of the library and the lack of documentation, so integrating d3 and Scrollama with React was also a chore -- props to Steph for her hard work on that.
We split the actual coding: Vincent did treemap, sankey, map stuff and Steph did layout/design, bar chart, and bubble chart.

Title: Exploring Language Diversity

To run, cd into /languages directory, npm install, then npm start.

Citations:
We downloaded language data and read articles from from Ethnologue.com and Glottologue.com
We borrowed a lot of insight from "A World Empire by Other Means" (http://www.economist.com/node/883997)
GeoJSON data was taken from https://github.com/johan/world.geo.json/blob/master/countries.geo.json
Created using Scrollama.js, Uber's React-vis library, and d3.js
