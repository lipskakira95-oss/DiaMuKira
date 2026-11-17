// Browser smoke uses installed Chrome; all downloaded modules and profile data stay in the project.
package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/chromedp/chromedp"
	"log"
	"time"
)

func clickText(text string) chromedp.ActionFunc {
	return func(ctx context.Context) error {
		quoted, _ := json.Marshal(text)
		var id string
		expression := fmt.Sprintf(`(()=>{const node=[...document.querySelectorAll('flt-semantics[flt-tappable]')].find(el=>((el.getAttribute('aria-label')||'')+' '+el.textContent).includes(%s));return node?'#'+node.id:''})()`, quoted)
		if err := chromedp.Run(ctx, chromedp.Poll(expression, &id, chromedp.WithPollingInterval(100*time.Millisecond))); err != nil {
			return err
		}
		return chromedp.Run(ctx, chromedp.Click(id, chromedp.ByQuery), chromedp.Sleep(150*time.Millisecond))
	}
}

func main() {
	url := flag.String("url", "http://127.0.0.1:8080/", "running compiled app")
	chrome := flag.String("chrome", `C:/Program Files/Google/Chrome/Application/chrome.exe`, "installed Chrome")
	profile := flag.String("profile", "../../.local/browser-smoke", "project-local Chrome profile")
	flag.Parse()
	opts := append(chromedp.DefaultExecAllocatorOptions[:], chromedp.ExecPath(*chrome), chromedp.UserDataDir(*profile), chromedp.Flag("disable-dev-shm-usage", true))
	allocator, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	defer cancel()
	browser, closeBrowser := chromedp.NewContext(allocator)
	defer closeBrowser()
	ctx, timeout := context.WithTimeout(browser, 90*time.Second)
	defer timeout()
	var ready bool
	err := chromedp.Run(ctx, chromedp.Navigate(*url), chromedp.Poll(`document.querySelector('flt-semantics-placeholder')!==null`, &ready),
		chromedp.Evaluate(`document.querySelector('flt-semantics-placeholder').click()`, nil),
		clickText("Розпочнімо"), clickText("Діти 5–12 років"), clickText("Раунд 1"))
	if err != nil {
		log.Fatal(err)
	}
	for index, answer := range []string{"Так", "Ні", "Так", "Ні", "Ні", "Так", "Так"} {
		next := "Далі"
		if index == 6 {
			next = "Завершити раунд"
		}
		if err = chromedp.Run(ctx, clickText(answer), clickText(next)); err != nil {
			log.Fatal(err)
		}
	}
	var result bool
	if err = chromedp.Run(ctx, chromedp.Poll(`[...document.querySelectorAll('flt-semantics')].some(el=>(el.getAttribute('aria-label')||el.textContent).includes('7 із 7'))`, &result), clickText("Повторити")); err != nil {
		log.Fatal(err)
	}
	fmt.Println("BROWSER SMOKE PASS: welcome -> category -> 7 answers -> 7/7 -> retry")
}
