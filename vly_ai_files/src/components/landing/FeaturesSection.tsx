// TODO: UPDATE THE TEXT TO REFLECT THE APP MARKETING
import React, { useEffect } from "react";
import { CloudIcon, LockIcon, RefreshCcwIcon } from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { cn } from "@/lib/utils";
import { motion, useAnimation } from "framer-motion";
import { useInView } from "react-intersection-observer";

const features = [
  {
    name: "Push to deploy",
    description:
      "Commodo nec sagittis tortor mauris sed. Turpis tortor quis scelerisque diam id accumsan nullam tempus. Pulvinar etiam lacus volutpat eu. Phasellus praesent ligula sit faucibus.",
    href: "https://crack.diy",
    icon: CloudIcon,
  },
  {
    name: "SSL certificates",
    description:
      "Pellentesque enim a commodo malesuada turpis eleifend risus. Facilisis donec placerat sapien consequat tempor fermentum nibh.",
    href: "https://crack.diy",
    icon: LockIcon,
  },
  {
    name: "Simple queues",
    description:
      "Pellentesque sit elit congue ante nec amet. Dolor aenean curabitur viverra suspendisse iaculis eget. Nec mollis placerat ultricies euismod ut condimentum.",
    href: "https://crack.diy",
    icon: RefreshCcwIcon,
  },
];

export function FeaturesSection() {
  const controls = useAnimation();
  const [ref, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1,
  });

  useEffect(() => {
    if (inView) {
      controls.start("visible");
    }
  }, [controls, inView]);

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2,
      },
    },
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 50 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  const headerVariants = {
    hidden: { opacity: 0, y: 30 },
    visible: {
      opacity: 1,
      y: 0,
      transition: {
        duration: 0.6,
        ease: "easeOut",
      },
    },
  };

  return (
    <section className="container py-24 px-4">
      <motion.div 
        initial="hidden"
        animate="visible"
        variants={headerVariants}
        className="mx-auto max-w-2xl text-center"
      >
        <h3 className="text-sm font-semibold bg-gradient-to-r from-pink-600 via-purple-600 to-blue-600 bg-clip-text text-transparent">Deploy faster</h3>
        <h2 className="mt-2 text-4xl font-bold tracking-tight text-foreground sm:text-5xl">
          Edit this features section
        </h2>
        <p className="mt-6 text-lg text-muted-foreground">
          List out your project's features here and describe them to the user. This section provides a great opportunity to showcase your project's unique selling points.
        </p>
      </motion.div>

      <motion.div 
        ref={ref}
        initial="hidden"
        animate={controls}
        variants={containerVariants}
        className="mx-auto mt-16 grid max-w-2xl grid-cols-1 gap-8 sm:mt-20 lg:mt-24 lg:max-w-none lg:grid-cols-3"
      >
        {features.map((feature) => (
          <motion.div key={feature.name} variants={itemVariants}>
            <Card className="border-0 shadow-none bg-transparent">
              <CardHeader className="p-0">
                <div className="flex items-center gap-x-3">
                  <feature.icon className="h-5 w-5 text-pink-600" aria-hidden="true" />
                  <CardTitle className="text-lg font-semibold text-foreground">
                    {feature.name}
                  </CardTitle>
                </div>
              </CardHeader>
              <CardContent className="mt-4 p-0">
                <p className="text-muted-foreground">{feature.description}</p>
                <div className="mt-6">
                  <Button variant="link" className="p-0 text-purple-600 hover:text-blue-600" asChild>
                    <a href={feature.href}>
                      Learn more <span aria-hidden="true">→</span>
                    </a>
                  </Button>
                </div>
              </CardContent>
            </Card>
          </motion.div>
        ))}
      </motion.div>
    </section>
  );
}
