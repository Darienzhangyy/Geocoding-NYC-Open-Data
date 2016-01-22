[![wercker status](https://app.wercker.com/status/56cceaf2d32d66129b6187a33926aa37/m "wercker status")](https://app.wercker.com/project/bykey/56cceaf2d32d66129b6187a33926aa37)

#Background

New York City is at the forefront of the open data movement among local, state and federal governments. They have made publicly available a huge amount of data (NYC Open Data) on everything from street trees, to restaurant inspections, to parking violations. For this homework assignment we will be looking at a database of calls made to New York City’s 311 service which provides government information and non-emergency services.

This will be our first foray in to bigish data as the CSV file containing these data is roughly 6 gigabytes in size and contains 10 million observations over 48 variables. This is not so big that we can’t run our analyses on a moderately powerful laptop, but it is large enough that we need to start paying attention to what we are doing and the performance of our code.

The data contains all 311 requests from all five boroughs of New York City between January 1st, 2010 and October 6th, 2015. This data (nyc_311.csv) and additional supplementary data is available on saxon in my Sta523 data folder under nyc: /home/vis/cr173/Sta523/data/nyc/. We will introduce and discuss the additional supplementary datasets in class.



#1 - Geocoding

The 311 data contains a large number of variables that we do not care about for the time being. For your first task you will need to geocode as much of the data as possible using the given variables. Note that this data has had minimal cleaning done, there are a large number of errors, omissions, and related issues. Also, note that there is a very large number of requests made, 10 million over the course of the last 5 years. Even under the most optimistic of circumstances you will not be able to, nor should you, use any of the standard web based geocoding services.

In order to be successful at this task you do not need to geocode every address, or even most addresses. The goal is to geocode as many as possible with as much accuracy as possible to enable you to be successful with the 2nd task. This is a messy, large, and complex data set and at the best of times geocoding is a very difficult problem - go for the low hanging fruit first and then work on the edge cases / exceptions later as needed.

Your write up for this task should include a description of any and all cleaning / subsetting / etc. that was done to the data, as well as a description of your geocoding approach(es) and a discussion of how successful each was.


#2 - Recreating NYC’s Boroughs

The primary goal of this assignment is to attempt to reconstruct the boundaries of the 5 city boroughs. The data set contains the column, Borough, that lists the borough in which the request ostensibly originated from. Your goal is to take this data along with the geocoded locations from Task 1 and generate a set of spatial polygons (in the GeoJSON format) that represents the boundary of these borough.

As mentioned before, the data is complex and messy so keep in mind that there is no guarantee that the reported borough is correct, or the street address, or even your geocoding. As such, the goal is not perfection, anything that even remotely resembles the borough map will be considered a success. No single approach for this estimation is likely to work well, and an iterative approach to cleaning and tweaking will definitely be necessary. I would suggest initially focusing on a borough to develop your methods before generalizing to the entirety of New York City.

To make things more interesting I will be offering a extra credit for the team that is best able to recreate the borough map as judged by the smallest total area of discrepancy between your predicted polygons and the true map. In order to win the extra credit you must abide by the rules as detailed below. I will maintain a leader board so that you will be able to judge how well you are doing relative to the other teams in the class.

For this task you are expected to produce a GeoJSON file called boroughs.json, for details on formatting see the hw_example repo. Your write up should include a discussion of your approaches to generating the boundaries and at least a simple visualization of your boundaries on top of the Manhattan borough boundaries.

#3 - Visualization

The final task you will need to complete for this assignment is a novel visualization of the data - this will be left wholly open ended. The only constraint is that you are limited to only a single plot and you should make it as interesting and informative as possible (it does not need to involve geospatial data or the borough map). You should also include a brief writeup that describes how the visualization is constructed and why you chose this specific aspect of the data to visualize.
