export { }
declare global {
    interface Window { google?: any }
    interface Window { FB?: any; fbAsyncInit: () => void }
}
