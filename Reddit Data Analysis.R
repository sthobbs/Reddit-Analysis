# Install and load packages
install.packages("ggplot2")
install.packages("RMySQL")
install.packages("scales")
install.packages("reshape2")
library(ggplot2)
library(RMySQL)
library(scales)
library("reshape2") # melt


# Open connection to MySQL database
con<-dbConnect(MySQL(),user="root",password="",db="db2",host="localhost")


# Read in the database 
# lot is a list of data frames. Element i is post_ranki for the MySQL database
lot<-list()
for (i in 1:100){
    suppressWarnings(lot[[i]]<-dbReadTable(con,paste0("post_rank",i)))
}


# Close connection
dbDisconnect(con)


# Create some data frames to work with
post_rank1<-lot[[1]] # Top post data frame
top5_post_rank<-post_rank1 # Top 5 posts data frame
for (i in 2:5){
    top5_post_rank<-rbind(top5_post_rank,lot[[i]])
}
top10_post_rank<-top5_post_rank # Top 10 posts data frame
for (i in 6:10){
    top10_post_rank<-rbind(top10_post_rank,lot[[i]])
}
p1_post_rank<-top10_post_rank # Top 25 posts data frame (front page/page 1)
for (i in 11:25){
    p1_post_rank<-rbind(p1_post_rank,lot[[i]])
}
full_post_rank<-p1_post_rank # Top 100 posts data frame
for (i in 26:100){
    full_post_rank<-rbind(full_post_rank,lot[[i]])
}


# The post url can be derived from the data as follows
# go to https://www.reddit.com/r/subreddit/xxxxxx
# where subreddit is the value in the 'subreddit' column
# and xxxxxx is the last 6 digits of the value in the 'name' column
# e.g. For the number 7 post, at time unit 6, go to
paste0("https://www.reddit.com/r/",lot[[7]]$subreddit[6],"/",substring(lot[[7]]$name[6],4,9))



##### Plots #####

## Distribution of how long a post is on the front page (given that it reaches
## the front page)

# We need to end the time window before any current front page posts reached
# the front page so that the lower (left) tail is not inflated. It is still
# possible that some of the posts that were included (which went off the
# front page a while ago) will come back to the front page and bias the result.
# However, this probably isn't the case, so the approximation is reasonable.

# EDIT: I forgot to remove the initial post, changing code now.

# Start collecting data ----- Start time ------------ end time ----- current time
# in other words we look at all posts from start time to end time, then from
# end time to current time we continue to track posts that were in the first
# interval but we don't look at any new ones. We also posts that were in the
# Top at the start of data collections. This elimiates almost all if not
# all of the bias from our density estimate.

# Picking the appropriate time window for data we should use
current_posts<-NULL # 'names' of all post currently on the front page
for (i in 1:25){
    current_posts[i]<-lot[[i]]$name[nrow(lot[[1]])]
}
time_window_endpoint<-1
time_posts<-0
# Look forward from time 1 until I first encounter one of the current top posts
while (!any(time_posts%in%current_posts)){
    for (i in 1:25){
        time_posts[i]<-lot[[i]]$name[time_window_endpoint]
    }
    time_window_endpoint=time_window_endpoint+1
}
time_window_endpoint=time_window_endpoint-1

start_posts<-NULL # 'names' of all post currently on the front page
for (i in 1:25){
    start_posts[i]<-lot[[i]]$name[1]
}
time_window_startpoint<-nrow(lot[[1]])
time_posts<-0
# Look backwards until I first encounter one of the starting top posts
while (!any(time_posts%in%start_posts)){
    for (i in 1:25){
        time_posts[i]<-lot[[i]]$name[time_window_startpoint]
    }
    time_window_startpoint=time_window_startpoint-1
}
time_window_startpoint=time_window_startpoint+1

# Now we have a time window that ends right before the first appearence of the
# current top posts.

# Determine the unique names in the time window #and look at the frequencies
p1_post_names_int<-NULL
for (i in 1:25){
    p1_post_names_int<-unique(c(p1_post_names_int,lot[[i]]$name[time_window_startpoint:time_window_endpoint]))
}

# Collect names from all time which are in the time interval
p1_post_names_trunc<-NULL
for (i in 1:25){
    p1_post_names_trunc<-c(p1_post_names_trunc,lot[[i]]$name[lot[[i]]$name%in%p1_post_names_int])
}

time_dist_df<-data.frame(hours=as.vector(sort(table(p1_post_names_trunc)))/6)



# Plot density approximation
ggplot(time_dist_df,aes(x=hours))+
    geom_density(aes(fill="a"),size=2)+
    geom_vline(xintercept=mean(time_dist_df$hours))+
    ggtitle("Density Estimate of How Long a Post Lasts on the Front Page")+
    theme(legend.position="none")+
    annotate("text", label = "mean", x = mean(time_dist_df$hours)+0.83, y = 0.078, size = 6, colour = "black")

# Mean time a front page post spends on the front page
mean(time_dist_df$hours)



## Historical positions of the current top n posts

n<-25

# Formatting the data
post_tracking_df<-data.frame(time=(-nrow(lot[[1]])+1):0)
cur_top_post_names<-NULL # Current top n post names
for (i in 1:n){
    cur_top_post_names[i]<-lot[[i]]$name[nrow(lot[[1]])]
    rank<-rep(100,nrow(lot[[1]])) # Vector of rank positions over time
    for (t in 1:nrow(lot[[1]])){ # Time int
        for (pos in 1:100){ # Post rank position
            if (cur_top_post_names[i]==lot[[pos]]$name[t]){
                rank[t]<-pos
                break
            }
        }
    }
    post_tracking_df<-cbind(post_tracking_df,rank)
}
names(post_tracking_df)<-c("time",cur_top_post_names)
post_tracking_df_long<-melt(post_tracking_df, id="time")  # convert to long format

# Plot (warnings are okay)
ggplot(data=post_tracking_df_long,aes(x=time/6, y=value, colour=variable,alpha=0.8))+
    geom_line()+
    ylim(100,1)+
    xlim((-sum(rowSums(post_tracking_df[,2:(n+1)]!=100)>0)-5)/6,0) +
    # x-axis limits calculated to be based how much info we have on these posts
    # + 5 extra time units
    ggtitle("Historical Positions of the Current Top 25 Posts")+
    xlab("Time (hours)")+
    ylab("Relative Position")+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
        axis.text.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=.5,face="plain"),
        axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
        axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
        axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))



## Historical Positions of the top n posts k hours ago

n<-10
k<-15 # Use an increment of 1/6

# Formatting the data
post_tracking_df<-data.frame(time=(-nrow(lot[[1]])+1):0)
top_post_names<-NULL # Top n post at specific time names
for (i in 1:n){
    top_post_names[i]<-lot[[i]]$name[nrow(lot[[1]])-6*k]
    rank<-rep(100,nrow(lot[[1]])) # Vector of rank positions over time
    for (t in 1:nrow(lot[[1]])){ # Time int
        for (pos in 1:100){ # Post rank position
            if (top_post_names[i]==lot[[pos]]$name[t]){
                rank[t]<-pos
                break
            }
        }
    }
    post_tracking_df<-cbind(post_tracking_df,rank)
}
names(post_tracking_df)<-c("time",top_post_names)
post_tracking_df_long<-melt(post_tracking_df, id="time")  # convert to long format

# Plot (warnings are okay)
ggplot(data=post_tracking_df_long,aes(x=time/6, y=value, colour=variable,alpha=0.8))+
    geom_line()+
    ylim(100,1)+
    xlim((-sum(rowSums(post_tracking_df[,2:(n+1)]!=100)>0)-5)/6,0) +
    # x-axis limits calculated to be how much info we have on these posts
    # + 5 extra time units. doesn't work well for large k.
    ggtitle(paste("Historical Positions of Top", n, "Posts", k, "Hours Ago"))+
    xlab("Time (hours)")+
    ylab("Relative Position")+
    geom_vline(xintercept=-k)+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))

    

## Bar plots of subreddit representation

# I couldn't find any built in option to sort the bar plot in descending order
# of frequency so I hacked this function together.

# Creates a bar plot, in descending order, of a factor (or character)
# variable var. Groups all frequencies less than x% into an "other"
# bar on the right.
# df is a data frame containing var
# percent is TRUE <=> use %s rather than counts for y-axis
sorted_bar_plot<-function(df,var,x=0,percent=TRUE){
    dfa<-df # Defining duplicate data frame to alter
    
    # So I can use the variable name as an argument
    arguments <- as.list(match.call())
    var = eval(arguments$var, dfa)
    
    dfa<-within(dfa,var<-as.character(var)) # If var is a factor variable, this makes it a character variable
    # Create a vector (sorted by frequencies) of all values with frequencies above the threshold
    levels<-names(sort(table(dfa$var)[table(dfa$var)>nrow(dfa)*x/100],decreasing=T))
    # If any values are below the threshold, then add an "other" bar
    if (!all(table(dfa$var)>=nrow(dfa)*x/100)){
        levels<-c(levels,"other")
        # Changing the values with frequencies below the threshold to "other"
        dfa$var[dfa$var%in%names(table(dfa$var)[table(dfa$var)<nrow(dfa)*x/100])]="other"
    }
    # Reordering levels based on frequencies, turning var into a factor (for the duplicate dataframe)
    dfa<-within(dfa,var<-factor(var,levels=levels))
    # Plot
    if (percent==T){
        p <- ggplot(dfa, aes(x = var)) +
            geom_bar(aes(y = (..count..)/sum(..count..),fill = ..count../sum(..count..)),col="black")
            scale_y_continuous(labels = percent_format())
    }
    else{
        p <- ggplot(dfa, aes(x = var)) +
            geom_bar(aes(y=..count..,fill=..count..),col="black")
    }
    return(p)
}


p<-sorted_bar_plot(post_rank1,subreddit,x=0)
p + ggtitle("Subreddit Representation of Top Post") +
    xlab("Subreddit") +
    ylab("Representation")+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))


p<-sorted_bar_plot(top5_post_rank,subreddit,x=0)
p + ggtitle("Subreddit Representation of Top 5 Posts") +
    xlab("Subreddit") +
    ylab("Representation")+
    theme(axis.text.x = element_text(angle=90, vjust=1))+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))


p<-sorted_bar_plot(top10_post_rank,subreddit,x=0)
p + ggtitle("Subreddit Representation of Top 10 Posts") +
    xlab("Subreddit") +
    ylab("Representation")+
    theme(axis.text.x = element_text(angle=90, vjust=1))+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))


p<-sorted_bar_plot(p1_post_rank,subreddit,x=0)
p + ggtitle("Subreddit Representation of Top 25 Posts") +
    xlab("Subreddit") +
    ylab("Representation")+
    theme(axis.text.x = element_text(angle=90, vjust=1))+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))


p<-sorted_bar_plot(full_post_rank,subreddit,x=0)
p + ggtitle("Subreddit Representation of Top 100 Posts") +
    xlab("Subreddit") +
    ylab("Representation")+
    theme(axis.text.x = element_text(angle=90, vjust=1))+
    theme(legend.position="none",text = element_text(size=16,vjust=1),
          axis.text.x = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"),
          axis.text.y = element_text(colour="black",size=12,angle=0,hjust=1,vjust=0,face="plain"),  
          axis.title.x = element_text(colour="black",size=12,angle=0,hjust=.5,vjust=0,face="plain"),
          axis.title.y = element_text(colour="black",size=12,angle=90,hjust=.5,vjust=.5,face="plain"))




## Historical Positions of the all posts in a specific subreddit

sub<-"funny"

# Formatting the data
post_tracking_df<-data.frame(time=(-nrow(lot[[1]])+1):0)
post_names<-NULL # All post names of posts in sub in the top 100
for (i in 1:100){
    post_names<-unique(c(post_names,lot[[i]]$name[lot[[i]]$subreddit==sub]))
}
for (i in 1:length(post_names)){
    rank<-rep(100,nrow(lot[[1]])) # Vector of rank positions over time
    for (t in 1:nrow(lot[[1]])){ # Time int
        for (pos in 1:100){ # Post rank position
            if (post_names[i]==lot[[pos]]$name[t]){
                rank[t]<-pos
                break
            }
        }
    }
    post_tracking_df<-cbind(post_tracking_df,rank)
}
names(post_tracking_df)<-c("time",post_names)
post_tracking_df_long<-melt(post_tracking_df, id="time")  # Convert to long format

# Plot
ggplot(data=post_tracking_df_long,aes(x=time/6, y=value, colour=variable,alpha=0.8))+
    geom_line()+
    ylim(100,1)+
    xlim((-sum(rowSums(post_tracking_df[,2:(n+1)]!=100)>0)-5)/6,0) +
    # x-axis limits calculated to be how much info we have on these posts
    # + 5 extra time units
    ggtitle(paste0("Historical Positions of all r/", sub, " Posts in the Top 100"))+
    xlab("Time (hours)")+
    ylab("Relative Position")+
    theme(legend.position="none")#+
    #geom_hline(yintercept=43)



## Prints the % of time that all posts came from unique subreddits
for (k in 1:50){
    count=0
    for (i in 1:nrow(lot[[1]])){
        fp_subs<-NULL
        for (j in 1:k){
            fp_subs<-c(fp_subs,lot[[j]]$subreddit[i])
        }
        if (length(unique(fp_subs))==k){
            count=count+1
        }
    }
    #if (count==nrow(lot[[1]])){
    #    print("at most one post from any subreddit on the front page at any time")
    print(paste0("the top ", k," posts were in unique subreddits ",100*count/nrow(lot[[1]]),"% of the time"))
}



