#include "rippleObject.h"

bool RippleObject::init(const char* filename,float gridSideLen /*= 8.0*/)
{
	this->setTouchEnabled(true);
	this->setSwallowsTouches(true);
	Size winSize = Director::getInstance()->getWinSize();
	m_rippleSprite=new CrippleSprite();
    m_rippleSprite->autorelease();
	m_rippleSprite->init(filename, gridSideLen);
	m_rippleSprite->setPosition(ccp(winSize.width/2, winSize.height/2));
    m_rippleSprite->scheduleUpdate();
    addChild(m_rippleSprite);

    return true;
}


void RippleObject::onTouchesEnded(const std::vector<Touch*>& touches, Event *unused_event)
{
    //Add a new body/atlas sprite at the touched location
     
    CCTouch* touch;
    
    for(auto  it = touches.begin(); it != touches.end(); it++)
    {
        touch = (CCTouch*)(*it);
        
        if(!touch)
            break;
        
        Vec2 location = touch->getLocationInView();
        
        location = CCDirector::sharedDirector()->convertToGL(location);
        //    cout<<"mos pos:"<<location.x<<" "<<location.y<<endl;
        break;
    }
}
void RippleObject::onTouchesMoved(const std::vector<Touch*>& touches, Event *unused_event)
{
     
    CCTouch* touch;
    for(auto  it = touches.begin(); it != touches.end(); it++)
    {
        touch = (CCTouch*)(*it);
        
        if(!touch)
            break;
        Vec2 location = touch->getLocationInView();
        location = CCDirector::sharedDirector()->convertToGL(location);
		m_rippleSprite->doTouch(location, 512, 12);
    }
    
}

void RippleObject:: onTouchesBegan(const std::vector<Touch*>& touches, Event *unused_event)
{
     
    CCTouch* touch;
	for(auto  it = touches.begin(); it != touches.end(); it++)
    {
        touch = (CCTouch*)(*it);
        if(!touch)
            break;
        
        Vec2 location = touch->getLocationInView();
        
        location = CCDirector::sharedDirector()->convertToGL(location);
        //  cout<<"mos pos:"<<location.x<<" "<<location.y<<endl;
		m_rippleSprite->doTouch(location, 512, 24);
     //   break;

    }
}
