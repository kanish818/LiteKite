import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import {
  TrendingUp,
  BarChart2,
  PieChart,
  LineChart,
  ArrowRight,
  Github,
  Linkedin,
} from "lucide-react";
import { motion } from "framer-motion";
import heroImg from "@/assets/HeroImg2.png";

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-[#0a0a0f] via-[#0f0f1a] to-[#0a0a0f]">
      {/* Ambient glows */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        <div className="absolute top-[-15%] left-[-10%] w-[600px] h-[600px] rounded-full bg-blue-600/10 blur-[120px]" />
        <div className="absolute bottom-[-15%] right-[-10%] w-[600px] h-[600px] rounded-full bg-indigo-600/10 blur-[120px]" />
      </div>

      {/* Navbar */}
      <nav className="relative z-10 flex justify-between items-center px-8 py-5 border-b border-white/5">
        <div className="text-white text-2xl font-bold tracking-tight">
          <span className="text-blue-400">Lite</span>Kite
        </div>
        <div className="flex space-x-3">
          <Link to="/login">
            <Button variant="ghost" className="text-gray-300 hover:text-white hover:bg-white/10">
              Sign in
            </Button>
          </Link>
          <Link to="/register">
            <Button className="bg-blue-600 hover:bg-blue-500 text-white border-0 shadow-lg shadow-blue-900/40">
              Get Started
            </Button>
          </Link>
        </div>
      </nav>

      <main className="relative z-10 container mx-auto px-6 py-8">
        {/* Hero Image */}
        <motion.div
          className="flex justify-center items-center mx-auto mb-10"
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.2 }}
        >
          <div className="relative">
            <div className="absolute inset-0 rounded-2xl bg-blue-500/10 blur-2xl" />
            <img
              src={heroImg}
              className="relative rounded-2xl w-[62%] mx-auto shadow-2xl shadow-black/60 border border-white/10"
            />
          </div>
        </motion.div>

        {/* Hero Text */}
        <div className="flex flex-col items-center gap-6 mb-14 text-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <motion.h1
              className="text-4xl lg:text-5xl font-bold mb-5 text-white max-w-4xl leading-tight"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.2, duration: 0.8 }}
            >
              All in one{" "}
              <span className="bg-gradient-to-r from-blue-400 to-indigo-400 bg-clip-text text-transparent">
                Mock-stock exchange.
              </span>{" "}
              Trade without real money.
            </motion.h1>
            <motion.p
              className="text-lg text-gray-400 mb-8 max-w-2xl mx-auto"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.4, duration: 0.8 }}
            >
              A free online platform to trade stocks, learn how to invest, get AI support
              and much more...
            </motion.p>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.6, duration: 0.8 }}
            >
              <Link to="/register">
                <Button
                  size="lg"
                  className="bg-blue-600 hover:bg-blue-500 text-white px-8 shadow-lg shadow-blue-900/40"
                >
                  Sign up for free
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Button>
              </Link>
            </motion.div>
          </motion.div>
        </div>

        {/* Stats */}
        <motion.section
          className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-20"
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6, duration: 0.8 }}
        >
          {[
            { icon: <LineChart className="h-7 w-7 text-blue-400" />, title: "100+", description: "Active Users" },
            { icon: <BarChart2 className="h-7 w-7 text-indigo-400" />, title: "500+", description: "Daily Trades" },
            { icon: <PieChart className="h-7 w-7 text-blue-400" />, title: "2", description: "Capital Markets" },
            { icon: <TrendingUp className="h-7 w-7 text-indigo-400" />, title: "24/7", description: "Market Access" },
          ].map((item, index) => (
            <motion.div
              key={index}
              className="bg-white/5 backdrop-blur-sm border border-white/10 rounded-xl p-6 text-white hover:bg-white/8 transition-colors"
              whileHover={{ scale: 1.04, y: -4 }}
              transition={{ type: "spring", stiffness: 300 }}
            >
              {item.icon}
              <h3 className="text-3xl font-bold mt-4 text-white">{item.title}</h3>
              <p className="text-gray-400 mt-1">{item.description}</p>
            </motion.div>
          ))}
        </motion.section>

        {/* Steps */}
        <motion.section
          className="text-center mb-20"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8, duration: 0.8 }}
        >
          <h2 className="text-3xl font-bold text-white mb-12">
            Start investing in minutes
          </h2>
          <div className="grid md:grid-cols-3 gap-8">
            {[
              { step: "1", title: "Create Account", description: "Quick and secure sign up process" },
              { step: "2", title: "Fund Account", description: "Get free virtual cash to practice" },
              { step: "3", title: "Start Trading", description: "Access to global markets" },
            ].map((item, index) => (
              <motion.div
                key={index}
                className="bg-white/5 border border-white/10 backdrop-blur-sm rounded-xl p-8 text-white"
                whileHover={{ scale: 1.04, y: -4 }}
                transition={{ type: "spring", stiffness: 300 }}
              >
                <div className="w-12 h-12 rounded-full bg-blue-600/20 border border-blue-500/30 text-blue-400 flex items-center justify-center font-bold text-xl mx-auto mb-5">
                  {item.step}
                </div>
                <h3 className="text-xl font-bold mb-2">{item.title}</h3>
                <p className="text-gray-400">{item.description}</p>
              </motion.div>
            ))}
          </div>
        </motion.section>
      </main>

      <footer className="relative z-10 py-8 border-t border-white/5">
        <div className="container mx-auto px-6 flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-gray-500 text-sm">&copy; 2026 LiteKite. All rights reserved.</p>
          <div className="flex items-center gap-4">
            <a
              href="https://github.com/kanish818/LiteKite"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-gray-400 hover:text-white transition-colors text-sm"
            >
              <Github className="h-5 w-5" />
              GitHub
            </a>
            <a
              href="https://www.linkedin.com/in/kanish818/"
              target="_blank"
              rel="noopener noreferrer"
              className="flex items-center gap-2 text-gray-400 hover:text-blue-400 transition-colors text-sm"
            >
              <Linkedin className="h-5 w-5" />
              LinkedIn
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
