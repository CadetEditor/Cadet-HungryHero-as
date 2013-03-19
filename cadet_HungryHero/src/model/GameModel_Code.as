package model
{
	import flash.utils.ByteArray;
	
	import cadet.components.processes.SoundProcess;
	import cadet.components.sounds.SoundComponent;
	import cadet.core.CadetScene;
	import cadet.events.RendererEvent;
	
	import cadet2D.components.core.Entity;
	import cadet2D.components.particles.PDParticleSystemComponent;
	import cadet2D.components.processes.WorldBounds2D;
	import cadet2D.components.renderers.Renderer2D;
	import cadet2D.components.skins.AbstractSkin2D;
	import cadet2D.components.skins.ImageSkin;
	import cadet2D.components.skins.MovieClipSkin;
	import cadet2D.components.textures.TextureAtlasComponent;
	import cadet2D.components.textures.TextureComponent;
	import cadet2D.components.transforms.Transform2D;
	import cadet2D.events.SkinEvent;
	
	import hungryHero.components.behaviours.HeroBehaviour;
	import hungryHero.components.behaviours.MagnetBehaviour;
	import hungryHero.components.behaviours.MoveBehaviour;
	import hungryHero.components.behaviours.ObstacleBehaviour;
	import hungryHero.components.behaviours.ParallaxBehaviour;
	import hungryHero.components.behaviours.ShakeBehaviour;
	import hungryHero.components.behaviours.SpeedUpBehaviour;
	import hungryHero.components.processes.BackgroundsProcess;
	import hungryHero.components.processes.EatParticlesProcess;
	import hungryHero.components.processes.GlobalsProcess;
	import hungryHero.components.processes.ItemsProcess;
	import hungryHero.components.processes.ObstaclesProcess;
	import hungryHero.components.processes.WindParticlesProcess;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;

	// This class constructs a CadetEngine 2D scene using the CadetEngine API
	public class GameModel_Code
	{
		public var cadetScene	:CadetScene;
		private var renderer	:Renderer2D;
		
		// ASSETS
		[Embed(source="../../bin-debug/files/assets/hungryHero/graphics/bgLayer1.jpg")]
		private var SkyAsset:Class;
		[Embed(source="../../bin-debug/files/assets/hungryHero/graphics/mySpriteSheet.png")]
		private var SpriteSheetAsset:Class;
		[Embed(source="../../bin-debug/files/assets/hungryHero/graphics/mySpriteSheet.xml", mimeType="application/octet-stream")]
		private var SpriteSheetXML:Class;

		[Embed(source="../../bin-debug/files/assets/hungryHero/particles/particleCoffee.pex", mimeType="application/octet-stream")]
		private var ParticleCoffeeXML:Class;		
		[Embed(source="../../bin-debug/files/assets/hungryHero/particles/particleMushroom.pex", mimeType="application/octet-stream")]
		private var ParticleMushroomXML:Class;
		
		// SOUNDS
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/eat.mp3')]
		private var EatSoundClass:Class;
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/coffee.mp3')]
		private var CoffeeSoundClass:Class;
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/mushroom.mp3')]
		private var MushroomSoundClass:Class;
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/bgGame.mp3')]
		private var MusicSoundClass:Class;
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/hit.mp3')]
		private var HitSoundClass:Class;
		[Embed(source='../../bin-debug/files/assets/hungryHero/sounds/hurt.mp3')]
		private var HurtSoundClass:Class;
		
		private var allSprites			:TextureComponent;
		private var allSpritesAtlas		:TextureAtlasComponent;
		
		private var parallaxSpeed		:int = -15;
		
		private var skySkin				:ImageSkin;
		private var hillsSkin			:ImageSkin;
		private var midgroundSkin		:ImageSkin;
		private var foregroundSkin		:ImageSkin;
		
		private var heroSkin			:MovieClipSkin;
		private var heroTransform2D		:Transform2D;
		
		private var parent				:starling.display.DisplayObjectContainer;
		
		private var eatSound			:SoundComponent;
		private var mushroomSound		:SoundComponent;
		private var coffeeSound			:SoundComponent;
		private var musicSound			:SoundComponent;
		private var hitSound			:SoundComponent;
		private var hurtSound			:SoundComponent;
		
		private var globals				:GlobalsProcess;
		
		private var heroStartX			:Number;
		private var heroStartY			:Number;
		
		private var shakeBehaviour		:ShakeBehaviour;
		
		private var coffeeParticles		:PDParticleSystemComponent;
		private var mushroomParticles	:PDParticleSystemComponent;
		
		public function GameModel_Code()
		{
		}
		
		public function init(parent:starling.display.DisplayObjectContainer):void
		{
			this.parent = parent;
			
			// Create a CadetScene
			cadetScene = new CadetScene();
			
			// Add a 2D Renderer to the scene
			renderer = new Renderer2D(true);
			renderer.viewportWidth = parent.stage.stageWidth;
			renderer.viewportHeight = parent.stage.stageHeight;
			renderer.addEventListener(RendererEvent.INITIALISED, rendererInitialised);
			cadetScene.children.addItem(renderer);
			renderer.enableToExisting(parent);
		}
		
		public function reset():void
		{
			globals.reset();
			globals.paused = true;
			
			heroTransform2D.x = heroStartX;
			heroTransform2D.y = heroStartY;
			
			shakeBehaviour.shake = 0;
		}
		
		public function dispose():void
		{
			cadetScene.dispose();
			parent.removeEventListener( Event.ENTER_FRAME, enterFrameHandler );	
		}
		
		private function rendererInitialised(event:RendererEvent):void
		{
			// Add the main texture to the scene
			allSprites = new TextureComponent();
			allSprites.bitmapData = new SpriteSheetAsset().bitmapData;
			cadetScene.children.addItem(allSprites);
			
			var xmlFile:ByteArray = new SpriteSheetXML();
			var xmlStr:String = xmlFile.readUTFBytes( xmlFile.length );
			
			// Add the main texture atlas to the scene
			allSpritesAtlas = new TextureAtlasComponent()
			allSpritesAtlas.texture = allSprites;
			allSpritesAtlas.xml = new XML( xmlStr );
			cadetScene.children.addItem(allSpritesAtlas);
			
			// Add the Global variables
			globals = new GlobalsProcess();
			globals.paused = true;
			cadetScene.children.addItem(globals);
			
			// Define WorldBounds
			var worldBounds:WorldBounds2D = new WorldBounds2D();
			cadetScene.children.addItem(worldBounds);
			worldBounds.top 	= 100;
			worldBounds.left 	= 0;
			worldBounds.right 	= 1024;
			worldBounds.bottom 	= 768 - 250;
			
			// Add ShakeBehaviour
			shakeBehaviour = new ShakeBehaviour();
			cadetScene.children.addItem(shakeBehaviour);
			shakeBehaviour.target = renderer;
			
			addSounds();
			addBackgrounds();
			addParticles();
			addHero();
			addItems();
			addObstacles();
			
			parent.addEventListener( Event.ENTER_FRAME, enterFrameHandler );	
		}
		
		private function addSounds():void
		{
			musicSound = new SoundComponent();
			musicSound.asset = new MusicSoundClass();
			musicSound.loops = 999;
			//musicSound.play();
			
			eatSound = new SoundComponent();
			eatSound.asset = new EatSoundClass();
			
			mushroomSound = new SoundComponent();
			mushroomSound.asset = new MushroomSoundClass();
			
			coffeeSound = new SoundComponent();
			coffeeSound.asset = new CoffeeSoundClass();
			
			hitSound = new SoundComponent();
			hitSound.asset = new HitSoundClass();
			
			hurtSound = new SoundComponent();
			hurtSound.asset = new HurtSoundClass();
			
			var soundProcess:SoundProcess = new SoundProcess();
			cadetScene.children.addItem(soundProcess);
			soundProcess.music = musicSound;
		}
		
		private function addBackgrounds():void
		{
			// Add the sky texture to the scene
			var skyTexture:TextureComponent = new TextureComponent();
			skyTexture.bitmapData = new SkyAsset().bitmapData;
			cadetScene.children.addItem(skyTexture);
			
			var backgroundsProcess:BackgroundsProcess = new BackgroundsProcess();
			cadetScene.children.addItem(backgroundsProcess);
			
			// Add the sky to the scene
			var sky:Entity = new Entity();
			cadetScene.children.addItem(sky);
			// Add an ImageSkin to the sky Entity
			skySkin = new ImageSkin();
			sky.children.addItem(skySkin);
			skySkin.texture = skyTexture;
			skySkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);

			// Add the background hills to the scene
			var hills:Entity = new Entity();
			cadetScene.children.addItem(hills);
			// Add an ImageSkin to the hills Entity
			hillsSkin = new ImageSkin();
			hills.children.addItem(hillsSkin);
			hillsSkin.textureAtlas = allSpritesAtlas;
			hillsSkin.texturesPrefix = "bgLayer2";
			hillsSkin.y = 440;
			hillsSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);

			// Add the midground to the scene
			var midground:Entity = new Entity();
			cadetScene.children.addItem(midground);
			// Add an ImageSkin to the midground Entity
			midgroundSkin = new ImageSkin();
			midground.children.addItem(midgroundSkin);	
			midgroundSkin.textureAtlas = allSpritesAtlas;
			midgroundSkin.texturesPrefix = "bgLayer3";	
			midgroundSkin.y = 510;
			midgroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);

			// Add the foreground to the scene
			var foreground:Entity = new Entity();
			cadetScene.children.addItem(foreground);
			// Add an ImageSkin to the foreground Entity
			foregroundSkin = new ImageSkin();
			foreground.children.addItem(foregroundSkin);
			foregroundSkin.textureAtlas = allSpritesAtlas;
			foregroundSkin.texturesPrefix = "bgLayer4";	
			foregroundSkin.y = 600;
			foregroundSkin.addEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);		
		}
		
		
		private function addHero():void
		{
			heroStartX = -200;
			heroStartY = parent.stage.stageHeight/2;
			
			// Add Hero entity to the scene
			var hero:Entity = new Entity();
			cadetScene.children.addItem(hero);
			// Add a 2D transform
			heroTransform2D = new Transform2D();
			heroTransform2D.x = heroStartX;
			heroTransform2D.y = heroStartX;
			hero.children.addItem(heroTransform2D);
			// Add an animatable MovieClipSkin
			heroSkin = new MovieClipSkin();
			heroSkin.textureAtlas = allSpritesAtlas;
			heroSkin.texturesPrefix = "fly_";
			heroSkin.loop = true;
			hero.children.addItem(heroSkin);
			// Add the HeroBehaviour
			var heroBehaviour:HeroBehaviour = new HeroBehaviour();
			hero.children.addItem(heroBehaviour);
		}
		
		private function addItems():void
		{
			// Add the Items Entity
			var itemsEntity:Entity = new Entity();
			cadetScene.children.addItem(itemsEntity);
			
			for ( var i:uint = 0; i < 5; i ++ ) {
				// Add an ImageSkin to the itemsEntity
				var imageSkin:ImageSkin = new ImageSkin();
				imageSkin.x = -1000;
				imageSkin.textureAtlas = allSpritesAtlas;
				imageSkin.texturesPrefix = "item"+(i+1);
				itemsEntity.children.addItem(imageSkin);				
			}
			
			// Add the Powerups Entity
			var powerupsEntity:Entity = new Entity();
			cadetScene.children.addItem(powerupsEntity);
			
			// Add Coffee powerup
			var powerup:Entity = new Entity();
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin();
			powerup.children.addItem(imageSkin);
			imageSkin.x = -1000;
			imageSkin.textureAtlas = allSpritesAtlas;
			imageSkin.texturesPrefix = "item6";
			var speedUpBehaviour:SpeedUpBehaviour = new SpeedUpBehaviour();
			speedUpBehaviour.collectSound = coffeeSound;
			speedUpBehaviour.particleEffect = coffeeParticles;
			speedUpBehaviour.targetTransform = heroSkin;
			powerup.children.addItem(speedUpBehaviour);
			
			// Add Mushroom powerup
			powerup = new Entity();
			powerupsEntity.children.addItem(powerup);
			imageSkin = new ImageSkin();
			powerup.children.addItem(imageSkin);
			imageSkin.x = -1000;
			imageSkin.textureAtlas = allSpritesAtlas;
			imageSkin.texturesPrefix = "item7";
			var magnetBehaviour:MagnetBehaviour = new MagnetBehaviour();
			powerup.children.addItem(magnetBehaviour);
			magnetBehaviour.collectSound = mushroomSound;
			magnetBehaviour.particleEffect = mushroomParticles;
			magnetBehaviour.targetTransform = heroSkin;
			
			// Add ItemsProcess
			var itemsProcess:ItemsProcess = new ItemsProcess();
			cadetScene.children.addItem(itemsProcess);
			itemsProcess.collectSound = eatSound;
			itemsProcess.itemsContainer = itemsEntity;
			itemsProcess.powerupsContainer = powerupsEntity;
			itemsProcess.hitTestSkin = heroSkin;
			// Add default MoveBehaviour to ItemsProcess
			var defaultMoveBehaviour:MoveBehaviour = new MoveBehaviour();
			itemsProcess.children.addItem(defaultMoveBehaviour);
			defaultMoveBehaviour.angle = 270;
		}
		
		private function addObstacles():void
		{
			var warningSkin:MovieClipSkin = new MovieClipSkin();
			cadetScene.children.addItem(warningSkin);
			warningSkin.textureAtlas = allSpritesAtlas;
			warningSkin.texturesPrefix = "watchOut_";
			warningSkin.loop = true;
			warningSkin.x = -1000;
			
			// Add the Obstacles Entity
			var obstaclesEntity:Entity = new Entity();
			cadetScene.children.addItem(obstaclesEntity);
			
			for ( var i:uint = 0; i < 3; i ++ ) {
				var obstacle:Entity = new Entity();
				// Add the default ImageSkin to the obstacle entity
				var defaultSkin:ImageSkin = new ImageSkin();
				obstacle.children.addItem(defaultSkin);
				defaultSkin.textureAtlas = allSpritesAtlas;
				defaultSkin.texturesPrefix = "obstacle"+(i+1);
				// Add the crash ImageSkin to the obstacle entity
				var crashSkin:ImageSkin = new ImageSkin();
				obstacle.children.addItem(crashSkin);
				crashSkin.textureAtlas = allSpritesAtlas;
				crashSkin.texturesPrefix = "obstacle"+(i+1)+"_crash";
				// Add the Transform2D to the obstacle entity
				var transform:Transform2D = new Transform2D();
				obstacle.children.addItem(transform);
				transform.x = -1000;
				// Add the ObstacleBehaviour to the obstacle entity
				var behaviour:ObstacleBehaviour = new ObstacleBehaviour();
				obstacle.children.addItem(behaviour);
				behaviour.defaultSkin = defaultSkin;
				behaviour.crashSkin = crashSkin;
				behaviour.warningSkin = warningSkin;
				// Finally, add the obstacle entity to the container entity
				obstaclesEntity.children.addItem(obstacle);				
			}
			
			// Helicopter Obstacle
			obstacle = new Entity();
			var defaultMcSkin:MovieClipSkin = new MovieClipSkin();
			obstacle.children.addItem(defaultMcSkin);
			defaultMcSkin.textureAtlas = allSpritesAtlas;
			defaultMcSkin.texturesPrefix = "obstacle4_0";
			defaultMcSkin.loop = true;
			// Add the crash ImageSkin to the obstacle entity
			crashSkin = new ImageSkin();
			obstacle.children.addItem(crashSkin);
			crashSkin.textureAtlas = allSpritesAtlas;
			crashSkin.texturesPrefix = "obstacle4_crash";
			// Add the Transform2D to the obstacle entity
			transform = new Transform2D();
			obstacle.children.addItem(transform);
			transform.x = -1000;
			// Add the ObstacleBehaviour to the obstacle entity
			behaviour = new ObstacleBehaviour();
			obstacle.children.addItem(behaviour);
			behaviour.defaultSkin = defaultMcSkin;
			behaviour.crashSkin = crashSkin;
			behaviour.warningSkin = warningSkin;
			// Finally, add the obstacle entity to the container entity
			obstaclesEntity.children.addItem(obstacle);
			
			var obstaclesProcess:ObstaclesProcess = new ObstaclesProcess();
			cadetScene.children.addItem(obstaclesProcess);
			obstaclesProcess.obstaclesContainer = obstaclesEntity;
			obstaclesProcess.hitTestSkin = heroSkin;
			obstaclesProcess.hitSound = hitSound;
			obstaclesProcess.hurtSound = hurtSound;
		}
		
		private function addParticles():void
		{
			var particleSkin:ImageSkin;
			var particlesEntity:Entity;
			
			// Add Eat particles Entity
			particlesEntity = new Entity();
			cadetScene.children.addItem(particlesEntity);
			
			// Add Eat particle Skin
			particleSkin = new ImageSkin();
			particlesEntity.children.addItem(particleSkin);
			particleSkin.textureAtlas = allSpritesAtlas;
			particleSkin.texturesPrefix = "particleEat";
			
			// Add EatParticlesProcess
			var eatParticlesProcess:EatParticlesProcess = new EatParticlesProcess();
			cadetScene.children.addItem(eatParticlesProcess);
			eatParticlesProcess.particlesContainer = particlesEntity;
			
			// Add Wind particles Entity
			particlesEntity = new Entity();
			cadetScene.children.addItem(particlesEntity);
			
			// Add Wind particle Skin
			particleSkin = new ImageSkin();
			particlesEntity.children.addItem(particleSkin);
			particleSkin.textureAtlas = allSpritesAtlas;
			particleSkin.texturesPrefix = "particleWindForce";
			
			// Add WindParticlesProcess
			var windParticlesProcess:WindParticlesProcess = new WindParticlesProcess();
			cadetScene.children.addItem(windParticlesProcess);
			windParticlesProcess.particlesContainer = particlesEntity;
			
			// Add ParticleCoffeeXML
			var xmlFile:ByteArray = new ParticleCoffeeXML();
			var xmlStr:String = xmlFile.readUTFBytes( xmlFile.length );
			var xml:XML = new XML(xmlStr);
			
			// Add Coffee ParticleSystemComponent
			coffeeParticles = new PDParticleSystemComponent(xml);
//			coffeeParticles.targetSkin = heroSkin;
			cadetScene.children.addItem(coffeeParticles);
			
			// Add ParticleMushroomXML
			xmlFile = new ParticleMushroomXML();
			xmlStr = xmlFile.readUTFBytes( xmlFile.length );
			xml = new XML(xmlStr);
			
			// Add Mushroom ParticleSystemComponent
			mushroomParticles = new PDParticleSystemComponent(xml);
//			mushroomParticles.targetSkin = heroSkin;
			cadetScene.children.addItem(mushroomParticles);
		}
		
		// ParallaxBehaviours need to be added after their Skin sibling is validated (before they make a copy of it)
		private function textureValidatedHandler( event:SkinEvent ):void
		{
			var parallax:ParallaxBehaviour;
			var skin:AbstractSkin2D = AbstractSkin2D(event.target);
			
			if ( skin == skySkin ) {
				// Add a ParallaxBehaviour to the sky Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.1;
				parallax.speed = parallaxSpeed;
				skySkin.parentComponent.children.addItem(parallax);
				skySkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			} else if ( skin == hillsSkin ) {
				// Add a ParallaxBehaviour to the hills Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.3;
				parallax.speed = parallaxSpeed;
				hillsSkin.parentComponent.children.addItem(parallax);
				hillsSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);	
			} else if ( skin == midgroundSkin ) {
				// Add a ParallaxBehaviour to the midground Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 0.6;
				parallax.speed = parallaxSpeed;
				midgroundSkin.parentComponent.children.addItem(parallax);
				midgroundSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);
			} else if ( skin == foregroundSkin ) {
				// Add a ParallaxBehaviour to the midground Entity
				parallax = new ParallaxBehaviour();
				parallax.depth = 1;
				parallax.speed = parallaxSpeed;
				foregroundSkin.parentComponent.children.addItem(parallax);
				foregroundSkin.removeEventListener(SkinEvent.TEXTURE_VALIDATED, textureValidatedHandler);				
			}
		}
		
		private function enterFrameHandler( event:Event ):void
		{
			cadetScene.step();
		}		
	}
}
















