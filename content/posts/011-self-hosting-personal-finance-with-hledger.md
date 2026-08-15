+++
date = "2026-08-09T00:00:00-04:00"
title = "[011] My Self Hosted Personal Finance Setup with Hledger"
author = "Christopher Coco"
cover = "/imgs/011/cover.png"
coverCaption = ""
keywords = ["Personal Finance", "Homelab", "Self Hosting", "Technology", "Kubernetes"]
description = "Learn about how I am using Hledger on my homelab to self host my personal finance setup."
+++

Its been a while since my last article about something that I have been working on for side projects. The last couple months have
been pretty busy for me. With the next step of the handheld project being learning electronics, I haven't really had the time to
sit down and work on learning that stuff (I will be starting soon though). So I decided to work on another little project that I came
up with being self hosting Hledger's Web UI on my Kubernetes cluster and developing some tooling around it for easy automatic uploads.
For those that do not know Hledger is a personal finance tool that you can use to keep track of your money. This was something that
would be helpful to me. I wanted some service to help me keep track of where I'm spending things but do not want to give data to
some SaaS. So this was the next best idea.

Unfortunately, I will not be showing an specific code examples for this article due to the information being more sensitive.

## What is Hledger And Why I Decided To Use It?

As mentioned in the introduction, Hledger is a personal finance tool. To be more specific it is a plain text accounting system.
It uses this concept called double-entry book keeping to track all things money related. I am not an accountant or a finance expert but
from my research: double entry book keeping is the practice of money that enters one account must exist somewhere else. Everything
in the account must sum up to zero. [This video](https://www.youtube.com/watch?v=lIGJzQw79hg&t=747s) was very useful in learning
the concepts behind this.

Beyond the accounting part of Hledger, because everything is plain text you can do a lot of automation and manipulation around it.
This makes it perfect for making a setup that uses some sort of CI workflow to automate getting data into it. Other solutions I looked
at all used some sort of database and not just plaintext so it would be harder to throw in a Git repo which is what I wanted to do.

Hledger uses a journal file that keeps track of all of your transactions then when you query it, does the calculations for you.
It also allows for importing journals to one main journal so you can break things up easily. There is also a feature that lets
you define rules and then parse CSV files to import data. That feature is the whole basis for the automation that I created.

Another advantage of Hledger is you can interact with it through a CLI and a Web UI. So as long as I have the Git repo cloned and up
to date on my system you do not need to be connected to the internet to query it. The CLI also lets you run the Web UI locally so
that is also an option.

Compared to the other software that I found that I could throw on my homelab to have nice graphs of where I'm spending my money,
this seemed to be the most flexible which is why I went to use it.

## Self Hosting and Building Automation Around Hledger

After choosing to use Hledger for this setup I began thinking about how I wanted this to work. For starters, I wanted to be able to
pull statements from my banks upload them somewhere and have everything automatically generate. So I took a look into the formats
that my bank provides and it was only PDF and HTML. Unfortunately no CSV but writing a script to parse HTML is not the hardest thing
in the world. I also took a look into how I could automate grabbing those statements but the email that I get saying they are ready
does not have them attached. The next thing was looking into the Hledger Web UI to see if it would fit my needs. It is more on the
simpler side but has a nice over time time graph and detailed information about transactions. If I ever find the need for more then
I can always make my own Web UI for it. 

So with the goals of wanting to just commit new data to a Git repo then having everything update, I started to get to work.

#### Infrastructure

Before I talk about the solution I want to touch upon my homelab infrastructure a little bit. I need to write a longer more complete
article talking about my homelab eventually to fully describe it but if you would like a little bit more of an overview check out
the [GitHub repo](https://github.com/cjcocokrisp/homelab) with the manifests for a lot of my stuff.

The TDLR of my infrastructure though, is that it is a Kubernetes cluster. My deployments are done with Argo CD. So my first thought
was to have the CI pipelines was to append the data then restart the Argo CD application but that was not needed due to the Hledger
Web UI automatically picking up new data. One thing that I do on my homelab is use an NFS on one of my machines for volumes for
deployments. The reason for this is because it is easier to get and actually manipulate the files for things that might need it.
I used this a lot with the Minecraft server I was hosting for my friends because changing out worlds, adding plugins, and making
back ups was a lot easier then normal. My Kubernetes nodes are run in Talos VMs. Talos is a stripped down Linux distro that only
includes the essential binaries for Kubernetes and a lot of things are API driven. This would mean everytime I wanted to get data
off of it I would need to use their CLI and find exact storage paths which might be a bit harder then just navigating to a location in
an NFS. I haven't noticed any bad performance with it so it works well for my needs. I would just have the Git repo live in the NFS
and then a CI pipeline can do stuff by SSHing into the machine.

So with all of that said, the Hledger Web UI is just a Kubernetes deployment with a volume to the data directory in on my NFS.
I was thinking I might need to make a container image for Hledger but there was [this](https://github.com/adept/hledger-docker)
image already made which helped a lot.

So all of this set up was going to run inside my Kubernetes cluster.

#### Gitea + Self Hosted Runners

One thing that I also decided pretty early on is I did not want any of this code or data to live in GitHub. I didn't want a company
to have my bank data and also it would be difficult to interact with my homelab machines due to them all being behind a Tailscale
tailnet.

Because of this, I decided to self host Gitea on my infrastructure. This was not that hard to set up and I just deployed it with the
helm chart that they provide. It was really easy to get going and I've had it up since like April with no issues. Getting the self
hosted runners setup was also easy. Because I was using an Argo CD application to deploy the helm chart, all I needed to do was turn
the app into a multi source one. This means I didn't need a separate app for the runner daemon deployment and just added the helm
chart for that one into the same application. The only other thing you needed to do was get a token from the normal Gitea instance
and add it in a secret to the runner.

#### Data Parsing

The next thing that I did was create a Go program to parse my bank statements. I started off by reading through some of the HTML of
the statements to get an overview of how its structured. Then I wrote a program that recursively parses the statements by account.
I am really happy with the way I wrote the code for this and I wish that I could show it but its in the private Gitea sorry. 

This data parsing script would be then used later in the CI pipelines that I will describe in a couple of sections. Not too much
fancy things to talk about with this script.

#### Repository & Hledger Set Up

The next step was setting up the data repository. Below is the structure of the repo:

```
.
└── hledger-data/
    ├── hledger/
    │   ├── generated/
    │   │   └── account/
    │   │       └── *.journal
    │   ├── rules/
    │   │   └── account.rules
    │   ├── main.journal
    │   └── accounts.ledger
    └── data/
        ├── html/
        │   └── *.html
        └── csv/
            └── *.csv
```

The first directory I'll talk about is the one that holds all of the data. Within there is just two directories one for the HTML
statements and then the generated CSV files.

The `hledger` directory is where things get more interesting because it shows a bit about the hledger setup. First there is the
`main.journal` file. This file is just a bunch of `include` statements that import all of the journals inside of the `generated`
directory and the `accounts.ledger` file. This gets everything set up really nicely because if I ever want to close the books at the
end of the year and then restart for the next year you can easily do that by just removing all the includes for the journals or making
a back up. The `accounts.ledger` file includes all of the accounts which are basically just categories for income and expenses. Next,
is the `rules` directory. Hledger supports rules to be able to parse CSVs with the import command. They are just simple if statements
that parse if that keyword is in the description and then puts it in the account. This is nice because I can update these rules 
as I find more trends and things that I want to add in. For things that don't find a category I have it default to unknown which
will be important later in one of the CI pipelines. Lastely is the `generated` directory. This is just where all of the journals
that are generated off the csv files are placed.

That's really it for the hledger and repo setup. So now that we have a data repo, a script to parse bank statements, and
a private Git server to hold everything. All that's left is to talk about the CI pipelines.

#### CI Pipelines

For CI for getting everything generated, placed, and updated I want to do a pull request based workflow. So there is 3 CI pipelines
that can run on a commit.

The first one is on every commit to the main branch. It checks the html directory to see if there is a new file. If there is a new
file it then goes and converts that new HTML file to a CSV file then uses hledger to generate the journals based on that new data.
After that it then goes and creates a new branch for those changes then opens a PR from that branch onto the main branch.

Once a PR is opened, there is a CI workflow that runs no all commits in a PR that checks to see if the unknown category is in the new
generated journals. If there is it fails. The main branch has a branch protection that won't let the PR be merged until there is all
the unknowns are gone. Once the PR is merged there is another CI workflow that will login to my server where the NFS is located and
pull the updated commits. 

That's the general workflow here: commit new HTML data, PR gets open, fix the transactions with an unknown account, merge PR,
everything gets synced. It works well and is really flexible.

## Potential Future Work

Eventually I want to make some improvements to this setup. For starters, it would be cool to have the HTML files automatically
grabbed from my bank. However this would be tough due to security and just finding a good way to do it. All I can really think of
is have something sit on my Gmail and wait to see an email from them saving the statement is ready. Then after that use a headless
browser to pull it.

The other improvement I want to make I just don't have the hardware for at the moment. I want to self host some LLM models on a
machine and add it into my homelab. With the hardware prices right now I can't see that happening anytime soon. I would have an LLM
be apart of the CI pipelines and try to automatically categorize any of transactions that have unknown. This would come with a whole
summary on the PR description so that would be cool.

## Conclusion

And with that this explains my self hosted hledger setup. I'm really happy with how I designed this and also implemented it. For the
most part everything was really smooth and there wasn't many troubles. Even though it took longer then I wanted to with just being
busy I now have it to be able to see my finances in one place. I can expand this in the future if I get accounts at another bank
and that will be really nice. The next thing I plan to work on like I said is learning electronics to continue working on the 
homemade game console. I also want to work on revamping my portfolio site too so that will probably be another project I aim to
finish by the end of the year. And with that, I hope you all enjoyed this article and maybe it even inspires you to use this on
your homelab.


