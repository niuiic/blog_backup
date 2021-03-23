if [ "$1" = "force" ];then
		rm -rf ./.deploy_git
		./node_modules/hexo-cli/bin/hexo clean
		./node_modules/hexo-cli/bin/hexo g
		./node_modules/hexo-cli/bin/hexo d -g
elif [ "$1" = "bp" ];then
		cd ..
		git clone https://github.com/niuiic/blog_backup
		mv ./blog_backup/.git .
		rsync -avz --delete ./Blogs/ ./blog_backup/
		mv .git ./blog_backup
		cd ./blog_backup
		git add .
		git commit -m "new modification"
		git pull origin master
		git push -u origin master
elif [ "$1" = "new" ];then
		./node_modules/hexo-cli/bin/hexo new "$2" 
elif [ "$1" = "s" ];then
		./node_modules/hexo-cli/bin/hexo s
else
		./node_modules/hexo-cli/bin/hexo clean
		./node_modules/hexo-cli/bin/hexo g
		./node_modules/hexo-cli/bin/hexo d
fi
