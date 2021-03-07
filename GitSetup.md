Create a new repository on the command line

```
echo "# geohunter" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/sentientbit/geohunter.git
git push -u origin main
```

Push an existing repository from the command line

```
git remote add origin https://github.com/sentientbit/geohunter.git
git branch -M main
git push -u origin main
```

Merge main into feat001 (any conflicts will be resolved inside feat001 branch)

```
git checkout main
git pull
git checkout feat001
git merge main
```

When you are ready (and resolved any conflicts) to merge feat001 into main:

```
git checkout main
git merge feat001
git push origin main
```

Switch back to your feature, and repeat the flow

```
git checkout feat001
```

Git global setup

```
git config --global user.name "UPSTREAM-USER"
git config --global user.email "UPSTREAM-EMAIL@SOMETHING"
```