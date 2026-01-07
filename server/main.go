package main

import (
	"flag"
	"fmt"
	"github.com/gin-gonic/gin"
	"yofc.update.server/routers"
)

func main() {
	r := gin.Default()
	routers.InitRouter(r)
	//使用flag包
	var port int
	flag.IntVar(&port, "p", 2000, "监听的端口")
	flag.Parse()
	panic(r.Run(fmt.Sprintf(":%d", port)))
}
