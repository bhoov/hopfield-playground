function app(selectorString) {
    console.log("App has been run!!")
    document.querySelector(selectorString).textContent = "SAMPLE JS HAS RUN"
    console.log("App finished running")
}

// export default app