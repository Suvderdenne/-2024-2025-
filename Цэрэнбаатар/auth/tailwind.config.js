/** @type {import('tailwindcss').Config} */
module.exports = {
    content: [
      './app/**/*.{js,ts,jsx,tsx}',    // For Next.js App Router
      './pages/**/*.{js,ts,jsx,tsx}',  // If using Pages Router too
      './components/**/*.{js,ts,jsx,tsx}',
    ],
    theme: {
      extend: {},
    },
    plugins: [require('daisyui')],
  }
  